#!/bin/bash

if [ "$1" = "--list" ]
then

  tf_env="stage"

  app_external_ip=`cd ../terraform/$tf_env && terraform output app_external_ip | grep -o -E '[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}'`
  db_external_ip=`cd ../terraform/$tf_env && terraform output db_external_ip | grep -o -E '[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}'`
  db_internal_ip=`cd ../terraform/$tf_env && terraform output db_internal_ip | grep -o -E '[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}'`

  #echo "app_external_ip = "$app_external_ip
  #echo "db_external_ip = "$db_external_ip
  #echo "db_internal_ip = "$db_internal_ip

  counter=1
  appservers=""
  app_hostvars=""

  for external_ip in $app_external_ip
  do
    if [ "$appservers" != "" ]
    then
      appservers+=", "
    fi
    appservers+="\"reddit-app$counter-$tf_env\""

    if [ "$app_hostvars" != "" ]
    then
      app_hostvars+=", "
    fi
    app_hostvars+="\"reddit-app$counter-$tf_env\": { \"ansible_host\": \"$external_ip\" }"

    ((counter++))
  done

  dbserver=""
  db_hostvars=""

  if [ "$db_external_ip" != "" ]
  then
    dbserver+="\"reddit-db-$tf_env\""

    if [ "$app_hostvars" != "" ]
    then
      app_hostvars+=", "
    fi

    db_hostvars+="\"reddit-db-$tf_env\": { \"ansible_host\": \"$db_external_ip\" }"
  fi

  all_vars=""

  if [ "$db_internal_ip" != "" ]
  then
    all_vars+="\"db_internal_ip\": \"$db_internal_ip\""
  fi

cat<<EOF
{
  "all": {
    "children": [
      "app",
      "db",
      "ungrouped"
    ],
    "vars": {
      $all_vars
    }
  },
  "app": {
    "hosts": [
      $appservers
    ]
  },
  "db": {
    "hosts": [
      $dbserver
    ]
  },
  "_meta": {
    "hostvars": {
      $app_hostvars
      $db_hostvars
    }
  }
}
EOF

else
  echo {}
fi
