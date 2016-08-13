STACK_NAME:=ec2-proxy
REGION:=sa-east-1
TIMESTAMP:=`date +"%Y%m%d-%H%M%S"`
TEMPLATE_DIR=templates

.PHONY: process_template

$(TEMPLATE_DIR)/stack.json:
	mkdir -p $(TEMPLATE_DIR)/
	cfndsl src/proxy_stack.rb | json_pp > templates/stack.json

create_stack: $(TEMPLATE_DIR)/stack.json
	aws cloudformation create-stack --stack-name=$(STACK_NAME) --region $(REGION) \
		--template-body file://$(PWD)/$(TEMPLATE_DIR)/stack.json | tee stacks/$(STACK_NAME).json

update_stack: $(TEMPLATE_DIR)/stack.json
	aws cloudformation update-stack --stack-name=$(STACK_NAME) --region $(REGION) \
		--template-body file://$(PWD)/$(TEMPLATE_DIR)/stack.json | tee stacks/$(STACK_NAME).json

delete_stack:
	aws cloudformation delete-stack --stack-name=$(STACK_NAME) --region $(REGION)

describe_stack:
	aws cloudformation describe-stacks --stack-name=$(STACK_NAME) --region $(REGION)


start_socks_proxy:
	ssh -i ~/private/keys/brazil-proxy.pem -o "StrictHostKeyChecking no" \
		ec2-user@`aws cloudformation describe-stacks --stack-name=$(STACK_NAME) --region $(REGION) \
		| jq '.Stacks[0].Outputs[0].OutputValue' | sed 's/\"//g'` \
	-ND 8888 sleep 99999


clean:
	rm -rf $(TEMPLATE_DIR)/*
