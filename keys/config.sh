cat > /home/vagrant/.ssh/config <<EOF
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
EOF

if [ ! -d "/root/.ssh" ]; then
    mkdir /root/.ssh
fi

cat > /root/.ssh/config <<EOF
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
EOF
