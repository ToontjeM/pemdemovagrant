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

. ./env.sh

if [ -d "pemdemobagrant" ]; then
  rm -rf pemdemovagrant
fi

# Repo
curl -1sLf "https://downloads.enterprisedb.com/$credentials/enterprise/setup.rpm.sh" | sudo -E bash
yum -y install tpaexec

cat >> ~/.bash_profile <<EOF
export PATH=$PATH:/opt/EDB/TPA/bin
export EDB_SUBSCRIPTION_TOKEN=${credentials}
export LC_ALL=en_US.UTF-8
EOFsud
#source ~/.bash_profile
export PATH=$PATH:/opt/EDB/TPA/bin
export EDB_SUBSCRIPTION_TOKEN=${credentials}


# Install dependencies
tpaexec setup

ip=192.168.56
cat > hostnames.txt << EOF
pg1 $ip.11
pg2 $ip.12
barman $ip.13
pemserver $ip.14
EOF

# Test
tpaexec selftest

# Create TPA environment.
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

# Difficult way to get a clean password from ansible
raw=$(tpaexec show-password pemdemovagrant enterprisedb)
IFS=$'\n' read -r clean <<< "$raw"
export EDBPASSWORD="$clean"

raw=$(tpaexec show-password pemdemovagrant dba)
IFS=$'\n' read -r clean <<< "$raw"
export DBAPASSWORD="$clean"

printf "${G}--- Initializing pgbench in database ${R}postgres${G} on ${R}pg1${G} and add crontab to run on 30 min intervals.\n"
PG1IP=192.168.0.211
ssh $PG1IP << EOF
sudo su - enterprisedb 
pgbench -h localhost -p 5444 -i -U enterprisedb postgres
echo "0,30 * * * * pgbench -h localhost -p 5444 -T 100 -c 10 -j 2 -U enterprisedb postgres" | crontab -
EOF

PEMSERVERIP=192.168.0.214
printf "${G}--- Provisioning complete. You can now access PEM on ${R}https://$PEMSERVERIP/pem${G} using userid ${R}enterprisedb${G} and password ${R}$EDBPASSWORD\n"
printf "${G}--- There is also a user ${R}dba${G} with password ${R}$DBAPASSWORD\n"