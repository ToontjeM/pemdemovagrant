#!/bin/bash

if [ `whoami` != "root" ]
then
  printf "You must execute this as root\n"
  exit
fi

if [ `hostname` != "node0" ]
then
  printf "You must run this from node0\n"
  exit
fi

export credentials=$(cat /vagrant/.edbtoken)

rm -rf speedy

# PGD 5.x
curl -1sLf "https://downloads.enterprisedb.com/$credentials/postgres_distributed/setup.rpm.sh" | sudo -E bash

yum -y install wget chrony tpaexec tpaexec-deps
# Config file: /etc/chrony.conf
systemctl enable --now chronyd
chronyc sources

cat >> ~/.bash_profile <<EOF
export PATH=$PATH:/opt/EDB/TPA/bin
export EDB_SUBSCRIPTION_TOKEN=${credentials}
EOF
#source ~/.bash_profile
export PATH=$PATH:/opt/EDB/TPA/bin
export EDB_SUBSCRIPTION_TOKEN=${credentials}


# Install dependencies
#tpaexec setup
tpaexec setup --use-2q-ansible

ip=192.168.1
cat > hostnames.txt << EOF
node1 $ip.11
node2 $ip.12
node3 $ip.13
node4 $ip.14
node5 $ip.15
node6 $ip.16
EOF

# Test
tpaexec selftest

tpaexec configure speedy \
    --architecture PGD-Always-ON \
    --redwood \
    --platform bare \
    --hostnames-from hostnames.txt \
    --edb-postgres-advanced 14 \
    --no-git \
    --location-names dc1 \
    --pgd-proxy-routing local \
    --hostnames-unsorted

# Modify pg_hba.conf
cp peedy/config.yml speedy/config.yml.1

# Remove keyring
sed -i 's/keyring/#keyring/' speedy/config.yml
sed -i 's/vault/#vault/' speedy/config.yml


# Provision
tpaexec provision speedy

# Copying ssh keys
rm -f speedy/id_speedy.pub
rm -f speedy/id_speedy
cp ~/.ssh/id_rsa.pub speedy/id_speedy.pub
cp ~/.ssh/id_rsa speedy/id_speedy

# Ping
tpaexec ping speedy

# Deploy
tpaexec deploy speedy
