pub_ip=`curl http://checkip.amazonaws.com`
sudo apt-add-repository ppa:ansible/ansible
sudo apt update -y
sudo apt-get install awscli -y
sudo apt-get install ansible -y
ansible-playbook -i inventory openvpn.yml
