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

source ./env.sh

if [ -d "pemcluster" ]; then
  rm -rf pemcluster
fi

if [ -d "pgcluster" ]; then
  rm -rf pgcluster
fi

printf "${G}--- \n"
printf "${G}--- Installing TPAexec.\n"
printf "${G}--- \n"

# Repo
curl -1sLf "https://downloads.enterprisedb.com/$credentials/enterprise/setup.rpm.sh" | sudo -E bash
yum -y install tpaexec

cat >> ~/.bash_profile <<EOF
export PATH=$PATH:/opt/EDB/TPA/bin
export EDB_SUBSCRIPTION_TOKEN=${credentials}
export LC_ALL=en_US.UTF-8
EOF
source ~/.bash_profile
#export PATH=$PATH:/opt/EDB/TPA/bin
#export EDB_SUBSCRIPTION_TOKEN=${credentials}

# Install dependencies
tpaexec setup

# Test
tpaexec selftest

printf "${G}--- \n"
printf "${G}--- Creating cluster definitions and provisioning cluster infrastructure.\n"
printf "${G}--- \n"

# Create share PEM server.
tpaexec configure pemcluster \
    --architecture M1 \
    --enable-efm \
    --redwood \
    --platform bare \
    --edb-postgres-advanced 15 \
    --no-git

cp pemcluster.yml pemcluster/config.yml

# Create Postgres environment.
tpaexec configure pgcluster \
    --architecture M1 \
    --enable-efm \
    --redwood \
    --platform bare \
    --edb-postgres-advanced 15 \
    --no-git

cp pgcluster.yml pgcluster/config.yml

# Provision
tpaexec provision pemcluster
tpaexec provision pgcluster

# Copying ssh keys
cp ~/.ssh/id_rsa.pub pemcluster/id_pemcluster.pub
cp ~/.ssh/id_rsa pemcluster/id_pemcluster
cp ~/.ssh/id_rsa.pub pgcluster/id_pgcluster.pub
cp ~/.ssh/id_rsa pgcluster/id_pgcluster

# add pem-clusters key to the ssh-agent (handy for `aws` platform)
eval `ssh-agent -s`
ssh-add pemcluster/id_pemcluster
ssh-keyscan -4 $PEMSERVERIP >> pgcluster/known_hosts
ssh-copy-id -f -i pgcluster/id_pgcluster.pub -o 'UserKnownHostsFile=tpa_known_hosts' vagrant@$PEMSERVERIP

printf "${G}--- \n"
printf "${G}--- Deploying PEM cluster.\n"
printf "${G}--- \n"

# Provision & eploy PEM
tpaexec deploy pemcluster

# Get PEM credentials
raw=$(tpaexec show-password pemcluster enterprisedb)
IFS=$'\n' read -r clean <<< "$raw"
echo enterprisedb:$clean > pem_creds
chmod 600 pem_creds
chown root:root pem_creds
export EDB_PEM_CREDENTIALS_FILE=/vagrant/pem_creds

printf "${G}--- \n"
printf "${G}--- Deploying Postgres cluster.\n"
printf "${G}--- \n"

# Provision & eploy PEM
tpaexec deploy pgcluster

# Difficult way to get a clean password from ansible
raw=$(tpaexec show-password pgcluster enterprisedb)
IFS=$'\n' read -r clean <<< "$raw"
export EDBPASSWORD="$clean"

raw=$(tpaexec show-password pgcluster dba)
IFS=$'\n' read -r clean <<< "$raw"
export DBAPASSWORD="$clean"

printf "${G}--- \n"
printf "${G}--- Initializing pgbench in database ${R}postgres${G} on ${R}pg1${G} and add crontab to run on 30 min intervals.\n"
printf "${G}--- \n"
PG1IP=192.168.0.211
ssh $PG1IP << EOF
sudo su - enterprisedb 
pgbench -h localhost -p 5444 -i -U enterprisedb postgres
echo "0,30 * * * * pgbench -h localhost -p 5444 -T 100 -c 10 -j 2 -U enterprisedb postgres" | crontab -
EOF

PEMSERVERIP=192.168.0.214
printf "${G}--- \n"
printf "${G}--- Provisioning complete. You can now access PEM on ${R}https://$PEMSERVERIP/pem${G} using userid ${R}enterprisedb${G} and password ${R}$EDBPASSWORD\n"
printf "\n"
printf "${G}--- There is also a user ${R}dba${G} with password ${R}$DBAPASSWORD\n"
printf "${G}--- \n"
