[![Build Status](https://travis-ci.com/Otus-DevOps-2019-11/sergetol_infra.svg?branch=master)](https://travis-ci.com/Otus-DevOps-2019-11/sergetol_infra)

# sergetol_infra

sergetol Infra repository

# HW11

- доработаны роли для возможности провижининга в Vagrant, в том числе и настройка nginx (*)

```
# в директории ansible:
vagrant up
# для проверки работы приложения:
curl http://10.10.10.20:9292
# или через nginx:
curl http://10.10.10.20
# затем:
vagrant destroy -f
```

- выполнено тестирование роли db при помощи Molecule и Testinfra

```
# в директории ansible/roles/db:
molecule create
molecule converge
molecule verify
# затем:
molecule destroy
# или все разом:
molecule test
```

- переключена сборка образов с помощью Packer на использование ролей app и db

```
# в директории ansible для проверки вне Packer на предварительно поднятой с помощью Terraform инфраструктуре:
ansible-playbook playbooks/packer_db.yml --limit db --tags install
ansible-playbook playbooks/packer_app.yml --limit app --tags ruby
# в корневой директории репозитория (пере)сборка образов с помощью Packer:
packer build -var-file=packer/variables.json packer/db.json
packer build -var-file=packer/variables.json packer/app.json
```

# HW10

- перенесены созданные плейбуки app и db в соответствующие роли

- созданы два ansible окружения stage и prod со своими настройками, включая dynamic inventory (*)

```
ansible-playbook playbooks/site.yml --check
ansible-playbook playbooks/site.yml

ansible-playbook -i environments/prod/inventory.gcp.yml playbooks/site.yml --check
ansible-playbook -i environments/prod/inventory.gcp.yml playbooks/site.yml
```

- изучено использование коммьюнити ролей на примере роли nginx

- изучено применение ansible-vault на примере задачи создания новых пользователей

```
ansible-vault encrypt environments/stage/credentials.yml
ansible-vault encrypt environments/prod/credentials.yml

ansible-vault edit environments/stage/credentials.yml
ansible-vault edit environments/prod/credentials.yml

ansible-vault decrypt environments/stage/credentials.yml
ansible-vault decrypt environments/prod/credentials.yml
```

- (**) написаны Travis CI тесты для PR и коммитов в master

  - выполняется packer validate для всех шаблонов
  - выполняется terraform validate и tflint для бакета и stage и prod окружений
  - выполняется ansible-playbook --syntax-check и ansible-lint для всех плейбуков

- в README.md добавлен бейдж со статусом билда

# HW9

- реализация: один ansible playbook, один сценарий

```
ansible-playbook reddit_app_one_play.yml --check --limit db --tags db-tag
ansible-playbook reddit_app_one_play.yml --limit db --tags db-tag

ansible-playbook reddit_app_one_play.yml --check --limit app --tags app-tag
ansible-playbook reddit_app_one_play.yml --limit app --tags app-tag

ansible-playbook reddit_app_one_play.yml --check --limit app --tags deploy-tag
ansible-playbook reddit_app_one_play.yml --limit app --tags deploy-tag
```

- реализация: один playbook, несколько сценариев

```
ansible-playbook reddit_app_multiple_plays.yml --tags db-tag --check
ansible-playbook reddit_app_multiple_plays.yml --tags db-tag

ansible-playbook reddit_app_multiple_plays.yml --tags app-tag --check
ansible-playbook reddit_app_multiple_plays.yml --tags app-tag

ansible-playbook reddit_app_multiple_plays.yml --tags deploy-tag --check
ansible-playbook reddit_app_multiple_plays.yml --tags deploy-tag

ansible-playbook reddit_app_multiple_plays.yml --check
ansible-playbook reddit_app_multiple_plays.yml
```

- реализация: несколько плейбуков

```
ansible-playbook site.yml --check
ansible-playbook site.yml
```

- сделана генерация dynamic inventory на основе terraform output vars

```
ansible-inventory -i inventory_tfoutput.sh --list
ansible all -i inventory_tfoutput.sh -m ping
```

- сделан dynamic inventory через плагин gcp_compute

```
ansible-inventory -i inventory.gcp.yml --list
ansible all -i inventory.gcp.yml -m ping
```

- переделан provision в packer с использованием ansible

```
packer validate -var-file=packer/variables.json packer/db.json
packer build -var-file=packer/variables.json packer/db.json

packer validate -var-file=packer/variables.json packer/app.json
packer build -var-file=packer/variables.json packer/app.json
```

# HW8

## Использование команд ansible

- примеры простых команд:

`ansible app -m shell -a 'ruby -v; bundler -v'`

`ansible db -m service -a name=mongod`

`ansible app -m service -a name=puma.service`

`ansible app -m git -a 'repo=https://github.com/express42/reddit.git dest=/home/appuser/reddit'`

## Выполнение простого плейбука

`ansible-playbook clone.yml`

- после удаления папки ~/reddit на app выполнение плейбука clone.yml на app закончится уже с changed=1,<br/>что будет свидетельствовать о том, что были произведены изменения

## Использование статического JSON inventory

- пример статического JSON inventory (inventory.static.json):<br/>(простое преобразование из YAML в JSON)

```
{
  "all": {
    "children": {
      "app": {
        "hosts": {
          "appserver": {
            "ansible_host": "35.228.122.135"
          }
        }
      },
      "db": {
        "hosts": {
          "dbserver": {
            "ansible_host": "35.228.55.239"
          }
        }
      }
    }
  }
}
```

## Простой пример использования динамического JSON inventory

- пример (результирующего) динамического JSON inventory (inventory.json):<br/>(можно проследить отличия от статического JSON inventory)

```
{
  "all": {
    "children": [
      "app",
      "db",
      "ungrouped"
    ]
  },
  "app": {
    "hosts": [
      "appserver"
    ]
  },
  "db": {
    "hosts": [
      "dbserver"
    ]
  },
  "_meta": {
    "hostvars": {
      "appserver": {
        "ansible_host": "35.228.122.135"
      },
      "dbserver": {
        "ansible_host": "35.228.55.239"
      }
    }
  }
}
```

- для работы с таким готовым динамическим JSON inventory можно использовать простой скрипт (inventory.sh):

```
#!/bin/bash
set -e

cat ./inventory.json
```

- использование этого скрипта затем необходимо прописать в ansible.cfg:

```
[defaults]
inventory = ./inventory.sh
```

# HW7

- terraform проект разбит на модули и дополнительно параметризован
- созданы два окружения: stage и prod
- создан новый storage backet с помощью terraform

Посмотреть содержимое бакета можно командой:

`gsutil ls -r gs://tf-state-strg-bckt/**`

- (*) настроено хранение стейт файла в GCS удаленном бэкенде

При хранении стейт файла в удаленном бэкенде корректно работает режим блокировок.<br/>При попытке запустить одновременно terraform apply одной и той же конфигурации из разных мест один из запусков будет неудачным с ошибкой Error locking state,<br/>потому как tflock-файл уже будет существовать, и будет выведена информация о существующей блокировке

- (**) в модули app и db добавлены provisioner для настройки и старта приложения;<br/>добавлена возможность отключения provisioner (переменная enable_provision)

# HW6

## Использование metadata в Terraform

- если metadata ssh-keys определена на уровне инстанса VM в terraform, то, если добавить ssh-ключ некого нового пользователя через веб-интерфейс GCE в проект, к уже созданным на этот момент через terraform машинам под этим новым пользователем можно будет сразу подключиться;<br/>после пересоздания через terraform таких машин подключение к ним также работает как под пользователями, присутствующими в metadata инстанса VM, так и под пользователями, добавленными через веб-интерфейс GCE в проект
- если же метаданные ssh-keys определить на уровне google_compute_project_metadata_item в terraform, то ssh-ключ некого нового пользователя, добавленый через веб-интерфейс GCE в проект, работать не будет;<br/>такой ключ будет потерян(удален) при terraform apply

## Использование count при создании инстансов VM

- использование count в google_compute_instance позволяет избежать копирования кода для создания новых подобных инстансов VM;<br/>текущее значение count можно использовать при задании значения name ресурса для обеспечения требуемой уникальности

## Использование балансировщика

- для примера использования созданы HTTP (lb.tf) и TCP (lb.tf.tcp) балансировщики запросов на umanaged группу инстансов

# HW5

- создан параметризованный шаблон для сборки базового образа с помощью Packer

`packer validate -var-file=./variables.json ./ubuntu16.json`

`packer validate -var-file=./variables.json.example ./ubuntu16.json`

`packer build -var-file=./variables.json ./ubuntu16.json`

- создан параметризованный шаблон для сборки полного (на основе базового) образа с помощью Packer

`packer validate -var-file=./files/variables.json ./immutable.json`

`packer validate -var-file=./files/variables.json.example ./immutable.json`

`packer build -var-file=./files/variables.json ./immutable.json`

- добавлен скрипт создания через gcloud виртуальной машины из подготовленного полного образа

```
gcloud compute instances create reddit-app \
  --boot-disk-size=10GB \
  --image-family=reddit-full \
  --machine-type=f1-micro \
  --tags=puma-server \
  --restart-on-failure
```

# HW4

testapp_IP = 35.228.243.121

testapp_port = 9292

## Использование startup-script:

```
gcloud compute instances create reddit-app \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=./startup.sh
```

- посмотреть startup script лог можно потом так:

`sudo journalctl -u google-startup-scripts.service`

## Использование startup-script-url:

- предварительно можно создать bucket и загрузить startup script туда:

`gsutil mb -l europe-north1 gs://sergetol-bucket/`

`gsutil cp ./startup.sh gs://sergetol-bucket/cloud-testapp/startup.sh`

- потом использовать команду:

```
gcloud compute instances create reddit-app \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --scopes storage-ro \
  --metadata startup-script-url=gs://sergetol-bucket/cloud-testapp/startup.sh
```

## Создание нового firewall правила:

```
gcloud compute firewall-rules create default-puma-server \
  --network default \
  --direction ingress \
  --action allow \
  --target-tags puma-server \
  --source-ranges 0.0.0.0/0 \
  --rules tcp:9292 \
  --no-disabled
```

# HW3

bastion_IP = 35.228.243.121

someinternalhost_IP = 10.166.0.3

## Для подключения к someinternalhost через bastion в одну команду:

`ssh -i ~/.ssh/appuser -A -J appuser@35.228.243.121 appuser@10.166.0.3`

[//]: # (`ssh -i ~/.ssh/appuser -J appuser@35.228.243.121 appuser@10.166.0.3`)

## Для подключения по алиасу к bastion и someinternalhost:

- создать файл ~/.ssh/config со следующим содержимым:

```
Host bastion
  User appuser
  Hostname 35.228.243.121
  Port 22
  IdentityFile ~/.ssh/appuser
  ForwardAgent yes

Host someinternalhost
  User appuser
  Hostname 10.166.0.3
  Port 22
  IdentityFile ~/.ssh/appuser
  ForwardAgent yes
  ProxyJump appuser@35.228.243.121
```

- далее для подключения можно использовать команды:

`ssh bastion`

`ssh someinternalhost`

## Прикручивание Lets Encrypt сертификата к Pritunl:

- в веб-интерфейсе Pritunl заходим в Settings
- там в поле Lets Encrypt Domain вводим, например,

`vpn.35-228-243-121.sslip.io`

где 35-228-243-121 это внешний IP Pritunl через `-`

- далее нажимаем Save, и Pritunl сам все сделает
