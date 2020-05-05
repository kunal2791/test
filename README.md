Ansible Role: OpenVPN
=========
An ansible role to install and configure OpenVPN server.

Salient Features
----------------
- This Role automates the VPN setup using OpenVPN.
The role consist of two meta files
- clientlist: Enter the namer of the client you want to add.
- revokelist: Enter the names of the client you want to revoke.

Supported OS
------------
  * Ubuntu

Dependencies
------------
* OpenVPN and EasyRSA

Step 1 — Installing OpenVPN and EasyRSA
---------------------------------------
$ sudo apt update
$ sudo apt install openvpn
$ wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.4/EasyRSA-3.0.4.tgz

OpenVPN:- OpenVPN is a TLS/SSL VPN. This means that it utilizes certificates in order to encrypt traffic between the server and clients.

EasyRSA:- To issue trusted certificates, you will set up your own simple certificate authority (CA). To do this, we will download the latest version of EasyRSA, which we will use to build our CA public key infrastructure (PKI).

Step 2 — Configuring the EasyRSA Variables and Building the CA
--------------------------------------------------------------
EasyRSA directory is a script called easyrsa which is called to perform a variety of tasks involved with building and managing the CA. Run this script with the init-pki option to initiate the public key infrastructure on the CA server:

$ ./easyrsa init-pki

$ ./easyrsa build-ca nopass

* ca.crt is the CA’s public certificate file which, in the context of OpenVPN, the server and the client use to inform one another that they are part of the same web of trust

* ca.key is the private key which the CA machine uses to sign keys and certificates for servers and clients.

Step 3 — Creating the Server Certificate, Key, and Encryption Files
-------------------------------------------------------------------
Now that you have a CA ready to go, you can generate a private key and certificate request from your server and then transfer the request over to your CA to be signed, creating the required certificate.

$ ./easyrsa gen-req server nopass

This will create a private key for the server and a certificate request file called server.req.

Then sign the request by running the easyrsa script with the sign-req option, followed by the request type and the common name.

$ ./easyrsa sign-req server server

Step 4 — Generating a Client Certificate and Key Pair
-----------------------------------------------------

Repeat step 3 to generate client cert and key.

Step 5 - Generating Client Configurations
-----------------------------------------
Now, we can create a client configuration client1.ovpn, using the certificate and key named client1.crt and client1.key, respectively, with running the script make_config.sh

It generate OVPN cert for user with using client configuration client.conf, user.crt , user.key ,ta.key.
 Client.conf contains information of server information, PORT, Auth, Encription etc.


make_config.sh
---------------
#!/bin/bash
# First argument: Client identifier
KEY_DIR=/etc/openvpn
OUTPUT_DIR=/etc/openvpn
BASE_CONFIG=/etc/openvpn/client.conf

cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/${1}.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/${1}.key \
    <(echo -e '</key>\n<tls-auth>') \
    ${KEY_DIR}/ta.key \
    <(echo -e '</tls-auth>') \
    > ${OUTPUT_DIR}/${1}.ovpn


Structure
--------
└── openvpn
    ├── README.md
    ├── clientaccess.yaml
    ├── clientlist
    ├── group_vars
    │   └── vpn
    ├── host_vars
    │   └── openvpnserver
    ├── inventory
    ├── openvpn.yml
    ├── revokelist
    └── roles
        └── openvpn
            ├── files
            │   └── make_config.sh
            ├── handlers
            │   └── main.yml
            ├── tasks
            │   ├── client_keys.yaml
            │   ├── config.yaml
            │   ├── easy-rsa.yaml
            │   ├── firewall.yaml
            │   ├── install.yaml
            │   ├── main.yaml
            │   ├── revoke.yaml
            │   └── server_keys.yaml
            └── templates
                ├── before.rules.j2
                ├── client.conf.j2
                └── server.conf.j2

How to Run Playbook
----------------
```
---
- name: It will automate OpenVPN client cert genetation and revoke
  hosts: all
  become: true
  roles:
    - role: openvpn
...

$  ansible-playbook openvpn.yml -i inventory

```
```
- For generating client keys
$  ansible-playbook client.yml -i inventory --tags "generate_client_keys"


- For revoking client keys
$  ansible-playbook client.yml -i inventory --tags "revoke_client_keys"

```

Reference:
---------
https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-18-04
