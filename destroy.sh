#!/usr/bin/env bash

for step in 06-entry-points 05-workers 04-masters 03-monitor 02-logcentral 01-landscape; do
    ansible-playbook \
    ../terrabot/terrabot.yml \
    -e tflayer=$step \
    -e deployment=prod-eu-west-1 \
    -e tfaction=destroy
done