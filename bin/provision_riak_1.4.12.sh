#! /bin/bash
source /vagrant/bin/provision_helper.sh

# provision_riak -- Installs and configures Riak as a cluster of 1

echo "Installing Riak..."

echo "* Checking for cached components"
if [ ! -f "/vagrant/data/rpmcache/riak-1.4.12-1.el6.x86_64.rpm" ] 
  then
    echo "   - Downloading Riak 1.4.12 Package into cache"
    wget -q --output-document=/vagrant/data/rpmcache/riak-1.4.12-1.el6.x86_64.rpm http://s3.amazonaws.com/downloads.basho.com/riak/1.4/1.4.12/rhel/6/riak-1.4.12-1.el6.x86_64.rpm 
fi

echo "* Installing Riak Package"
yum -y --nogpgcheck --noplugins localinstall \
  /vagrant/data/rpmcache/riak-1.4.12-1.el6.x86_64.rpm

if [ ! -d "/etc/riak" ] 
  then
    echo "No Riak directory found after installation.  Aborting..."
    exit 1
fi

echo "* Increasing File Limits"
echo '
# Added by Vagrant Provisioning Script
# ulimit settings for Riak
root soft nofile 65536
root hard nofile 65536
riak soft nofile 65536
riak hard nofile 65536

'  >> /etc/security/limits.conf

echo ""
echo "* Configuring node as riak@$IP_ADDRESS "
mv /etc/riak/vm.args /etc/riak/vm.args.orig
sed "s/riak@127.0.0.1/riak@$IP_ADDRESS/g" /etc/riak/vm.args.orig > /etc/riak/vm.args

insert_attribute riak riak@$IP_ADDRESS
insert_service riak riak@$IP_ADDRESS

echo "* Enabling and Starting Riak"
chkconfig riak on
service riak start
