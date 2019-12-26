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
