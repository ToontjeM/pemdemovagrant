echo "Copy public key..."

#mkdir /home/vagrant/.ssh
#mkdir /root/.ssh
cat /vagrant_keys/key.pub >> /home/vagrant/.ssh/authorized_keys
cat /vagrant_keys/key.pub >> /root/.ssh/authorized_keys

#https://levelup.gitconnected.com/how-to-connect-without-password-using-ssh-passwordless-9b8963c828e8
echo "*** Copying keys..."
cp /vagrant_keys/key.pub ~/.ssh/id_rsa.pub
cp /vagrant_keys/key ~/.ssh/id_rsa

cp /vagrant_keys/key.pub /home/vagrant/.ssh/id_rsa.pub
cp /vagrant_keys/key /home/vagrant/.ssh/id_rsa
chmod 666 /home/vagrant/.ssh/id*
echo "*** End copying keys..."
