#pub_ip=`curl http://checkip.amazonaws.com`
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update -y
sudo apt-get install ansible -y
sudo apt-get install git -y
sudo apt-get install awscli -y
git clone https://github.com/kunal2791/test.git
cd test
ansible-playbook -i inventory openvpn.yml --connection=local
