#!/usr/bin/env bash

for step in logstore 04-workers 03-masters 021-monitor 020-entry-points 01-landscape; do
    ansible-playbook plays/undeploy-tf-layer.yml -e auto_apply=true -e layer_name=$step -vvv
done