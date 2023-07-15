### Introduction

Ansible playbook for configuring various aspects of my homelab environment.

### infra-server

The infra server is the system which runs 24/7 and hosts a variety of processes including:

* haproxy
* pi.hole
* glauth (LDAP)
* upsnap (remote start)

Note that glauth hosts some basic users with the passwords store in vars/glauth.yaml which
has been encrypted with vault. This file has the following variables:

```
admin_password: xxxxx
user_password: xxxxxx
openshift_password: xxxxx
```

Which correspond to passwords used in the glauth config.cfg file. I'm currently using the SHA256
password hash in glauth, todo is to look at bcrypt in order to get it working with Ansible's
password_hash filter.

To configure the infra_server, run:

```
ansible-playbook -i inventory configure-infra-server.yaml  --ask-vault-pass
```
