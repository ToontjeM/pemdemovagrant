ip=$(/vagrant_keys/get_ip.sh)

cat >>/etc/hosts << EOF
$ip.10 node0 node0
$ip.11 node1 node1
$ip.12 node2 node2
$ip.13 node3 node3
$ip.14 node4 node4
$ip.15 node5 node5
$ip.16 node6 node6
EOF
