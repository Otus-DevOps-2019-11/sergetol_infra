db
==

Use this role to config MongoDB instance

Role Variables
--------------

defaults/main.yml:

```
# MongoDB port and IP to listen to
mongo_port: 27017
mongo_bind_ip: 127.0.0.1
```

Example Playbook
----------------

```
- name: Configure MongoDB
  hosts: db
  become: true
  vars:
    mongo_bind_ip: 127.0.0.1
  roles:
    - db
```
