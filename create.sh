#!/usr/bin/env bash

echo "$(date) - start deploy infra" > run.log

for step in 01-landscape 020-entry-points 021-monitor 03-masters 04-workers logstore; do
    ansible-playbook plays/deploy-tf-layer.yml -e auto_apply=true -e layer_name=$step -vvv
done

echo "$(date) - end deploy infra" >> run.log

sleep 300

ansible -m ping bastions

echo "$(date) - start ansible" >> run.log

ansible-playbook plays/configure.yml

echo "$(date) - end ansible" >> run.log
