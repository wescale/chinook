DEPLOY_OPTS=-e deploy_region=eu-west-1 -e deploy_env=dev -e tfaction=apply -e auto_apply=true -e post_apply_tasks=$(shell pwd)/plays/generate_tf_layer_inventory.yml ../terrabot/terrabot.yml -e auto_apply=true -e teardown_tasks=$(shell pwd)/plays/generate_tf_layer_inventory.yml
DESTROY_OPTS=-e deploy_region=eu-west-1 -e deploy_env=dev -e auto_apply=true -e tfaction=destroy ../terrabot/terrabot.yml

00-access-rights:
	ansible-playbook -e tflayer=00-access-rights $(DEPLOY_OPTS)


deploy_infra: 01-landscape
	ansible-playbook -e tflayer=01-landscape    $(DEPLOY_OPTS)
	ansible-playbook -e tflayer=02-logcentral   $(DEPLOY_OPTS)
	ansible-playbook -e tflayer=03-monitor      $(DEPLOY_OPTS)
	ansible-playbook -e tflayer=04-masters      $(DEPLOY_OPTS)
	ansible-playbook -e tflayer=05-workers      $(DEPLOY_OPTS)
	ansible-playbook -e tflayer=06-entry-points $(DEPLOY_OPTS)

01-landscape:
	ansible-playbook -e tflayer=01-landscape $(DEPLOY_OPTS)

02-logcentral: 01-landscape
	ansible-playbook -e tflayer=02-logcentral $(DEPLOY_OPTS)

03-monitor: 02-logcentral
	ansible-playbook -e tflayer=03-monitor $(DEPLOY_OPTS)

04-masters: 03-monitor
	ansible-playbook -e tflayer=04-masters $(DEPLOY_OPTS)

05-workers: 04-masters
	ansible-playbook -e tflayer=05-workers $(DEPLOY_OPTS)

06-entry-points: 05-workers
	ansible-playbook -e tflayer=06-entry-points $(DEPLOY_OPTS)

deploy_all: 06-entry-points
	sleep 300
	echo "Infrastructure is ready to use."

configure:
	ansible -m ping bastions
	echo "$(shell date) - start ansible" >> run.log
	ansible-playbook plays/configure.yml
	echo "$(shell date) - end ansible" >> run.log

deploy: deploy_infra configure

undeploy:
	ansible-playbook -e tflayer=06-entry-points $(DESTROY_OPTS)
	ansible-playbook -e tflayer=05-workers      $(DESTROY_OPTS)
	ansible-playbook -e tflayer=04-masters      $(DESTROY_OPTS)
	ansible-playbook -e tflayer=03-monitor      $(DESTROY_OPTS)
	ansible-playbook -e tflayer=02-logcentral   $(DESTROY_OPTS)
	ansible-playbook -e tflayer=01-landscape    $(DESTROY_OPTS)
