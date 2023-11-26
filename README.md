### Introduction

Ansible playbook for configuring various aspects of my homelab environment.

### Install

`ansible-galaxy role install mprahl.lets-encrypt-route-53`

### infra-server

The infra server is the system which runs 24/7 and hosts a variety of processes including:

* haproxy
* pi.hole
* glauth (LDAP)
* upsnap (remote start)
* homepage
* prometheus
* keycloak

Note that glauth hosts some basic users with the passwords store in vars/protected.yaml which
has been encrypted with vault. This file has the following variables:

```
admin_password: xxxxx
user_password: xxxxxx
openshift_password: xxxxx
```

Which correspond to passwords used in the glauth config.cfg file. I'm currently using the SHA256
password hash in glauth, todo is to look at bcrypt in order to get it working with Ansible's
password_hash filter.

Finally upsnap has an admin user which is automatically provisioned by ansible, this is also
stored in protected.yaml. The admin user in upsnap has the following variables defined:

```
upsnap_admin_username: xxx@xxx.xxx
upsnap_admin_password: xxx@xxx.xxx
```

Note that upsnap cannot be configured programmatically, currently the role uploads a backup file
I have which can then be restored. Note that this backup is not stored in git.

To configure the infra_server, run:

```
ansible-playbook -i inventory configure-infra-server.yaml  --ask-vault-pass
```
Or with an existing password file:
```
ansible-playbook -i inventory configure-infra-server.yaml --vault-password-file=.vault_pass
```
