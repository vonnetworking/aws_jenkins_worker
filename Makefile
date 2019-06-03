SEQ=001
EC2TYPE=t2.medium
#PUBLIC_IP := $(shell curl ipecho.net/plain)
PUBLIC_IP=0.0.0.0
create:
	echo $(PUBLIC_IP)
	#aws cloudformation create-stack --template-body file://./cf/devBox.yaml \
	#--stack-name $(USER)devBox --parameters ParameterKey=KeyName,ParameterValue=avSSH \
	#																				ParameterKey=SSHLocation,ParameterValue=$(PUBLIC_IP)/0 \
	#																				ParameterKey=InstanceType,ParameterValue=$(EC2TYPE)
	aws cloudformation create-stack --template-body file://./JenkinsWorker.yaml \
		--stack-name JenkinsWorker-${SEQ} --parameters file://./ci/JenkinsWorker_params.json

delete:
	aws cloudformation delete-stack --stack-name JenkinsWorker

describe:
	aws cloudformation describe-stacks --stack-name JenkinsWorker

ssh:
	ssh -i $$AWSKEY ec2-user@$$(make describe | grep -A 1 InstanceIPAddress | grep OutputValue | sed 's/\"//g' | awk -F': ' '{print $$2}')

recreate:
	make delete; sleep 60; make create; sleep 60; make describe

validate:
	aws cloudformation validate-template --template-body file://./JenkinsWorker.yaml
