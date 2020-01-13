# sergetol_infra
sergetol Infra repository

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

# HW6

## Использование metadata в Terraform

- если metadata ssh-keys определена на уровне инстанса VM в terraform, то, если добавить ssh-ключ некого нового пользователя через веб-интерфейс GCE в проект, к уже созданным на этот момент через terraform машинам под этим новым пользователем можно будет сразу подключиться;<br/>после пересоздания через terraform таких машин подключение к ним также работает как под пользователями, присутствующими в metadata инстанса VM, так и под пользователями, добавленными через веб-интерфейс GCE в проект
- если же метаданные ssh-keys определить на уровне google_compute_project_metadata_item в terraform, то ssh-ключ некого нового пользователя, добавленый через веб-интерфейс GCE в проект, работать не будет;<br/>такой ключ будет потерян(удален) при terraform apply

## Использование count при создании инстансов VM

- использование count в google_compute_instance позволяет избежать копирования кода для создания новых подобных инстансов VM;<br/>текущее значение count можно использовать при задании значения name ресурса для обеспечения требуемой уникальности
