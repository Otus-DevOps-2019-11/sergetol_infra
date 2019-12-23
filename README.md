# sergetol_infra
sergetol Infra repository

## Для подключения к someinternalhost через bastion в одну команду:
`ssh -i ~/.ssh/appuser -A -J appuser@35.228.243.121 appuser@10.166.0.3`
[//]: # (`ssh -i ~/.ssh/appuser -J appuser@35.228.243.121 appuser@10.166.0.3`)

## Для подключения по алиасу к bastion и someinternalhost:
- создать файл ~/.ssh/config со следующим содержимым:
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

- далее для подключения можно использовать команды:
      ssh bastion
      ssh someinternalhost
