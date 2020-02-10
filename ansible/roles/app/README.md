app
===

Use this role to config reddit-app instance

Role Variables
--------------

defaults/main.yml:

```
# MongoDB IP:port to connect app to
db_host: 127.0.0.1:27017
# Environment (e.g., stage, prod)
env: local
```

Example Playbook
----------------

```
- name: Configure App
  hosts: app
  become: true
  vars:
    db_host: 127.0.0.1:27017
  roles:
    - app
```
