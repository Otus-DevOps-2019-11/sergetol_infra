app
===

Use this role to config reddit-app instance

Role Variables
--------------

defaults/main.yml:

```
# MongoDB IP:port (or IP only) to connect app to
db_host: 127.0.0.1:27017
# Environment (e.g., stage, prod)
env: local
# Deploy user
deploy_user: appuser
```

Example Playbook
----------------

```
- name: Configure App
  hosts: app
  become: true
  vars:
    db_host: 127.0.0.1:27017
    env: local
    deploy_user: appuser
  roles:
    - app
```
