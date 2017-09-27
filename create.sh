#!/usr/bin/env bash

echo "$(date) - start deploy infra" > run.log

for step in 01-landscape 02-logcentral 03-monitor 04-masters 05-workers 06-entry-points; do
    ansible-playbook \
    ../terrabot/terrabot.yml \
    -e tflayer=$step \
    -e deployment=prod-eu-west-1 \
    -e tfaction=apply \
    -e auto_apply=true \
    -e teardown_tasks=$(pwd)/plays/generate_tf_layer_inventory.yml
done

echo "$(date) - end deploy infra" >> run.log

sleep 300

ansible -m ping bastions

echo "$(date) - start ansible" >> run.log

ansible-playbook plays/configure.yml

echo "$(date) - end ansible" >> run.log
