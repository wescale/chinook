#!/usr/bin/env bash
# 04-workers logstore; do
for step in 01-landscape 020-entry-points 021-monitor 03-masters; do
    ansible-playbook plays/deploy-tf-layer.yml -e auto_apply=true -e layer_name=$step -vvv
done

ansible-playbook plays/configure.yml