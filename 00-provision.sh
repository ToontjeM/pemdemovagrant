#!/bin/bash

if [ `whoami` != "root" ]
then
  printf "You must execute this as root\n"
  exit
fi

if [ `hostname` != "console" ]
then
  printf "You must run this from the console node.\n"
  exit
fi

export credentials=$(cat /vagrant/.edbtoken)

if [ -d "pemdemobagrant" ]; then
  rm -rf pemdemovagrant
fi

# Repo
curl -1sLf "https://downloads.enterprisedb.com/$credentials/enterprise/setup.rpm.sh" | sudo -E bash
export LC_ALL=en_US.UTF-8
yum -y install tpaexec

cat >> ~/.bash_profile <<EOF
export PATH=$PATH:/opt/EDB/TPA/bin
export EDB_SUBSCRIPTION_TOKEN=${credentials}
EOF
#source ~/.bash_profile
export PATH=$PATH:/opt/EDB/TPA/bin
export EDB_SUBSCRIPTION_TOKEN=${credentials}


# Install dependencies
#tpaexec setup
tpaexec setup

ip=192.168.1
cat > hostnames.txt << EOF
pg1 $ip.11
pg2 $ip.12
barman $ip.13
pemserver $ip.14
EOF

# Test
tpaexec selftest

tpaexec configure pemdemovagrant \
    --architecture M1 \
    --enable-efm \
    --redwood \
    --platform bare \
    --hostnames-from hostnames.txt \
    --edb-postgres-advanced 15 \
    --no-git \
    --hostnames-unsorted

# Modify pg_hba.conf
cp pemdemovagrant/config.yml pemdemovagrant/config.yml.1
cp configyml.backup pemdemovagrant/config.yml

# Provision
tpaexec provision pemdemovagrant

# Copying ssh keys
rm -f pemdemovagran/id_pemdemovagrant.pub
rm -f pemdemovagrant/id_pemdemovagrant
cp ~/.ssh/id_rsa.pub pemdemovagrant/id_pemdemovagrant.pub
cp ~/.ssh/id_rsa pemdemovagrant/id_pemdemovagrant

# Deploy
tpaexec deploy pemdemovagrant

#Selftest
tpaexec test pemdemovagrant -v