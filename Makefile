STACK_NAME:=ec2-proxy
REGION:=sa-east-1
TIMESTAMP:=`date +"%Y%m%d-%H%M%S"`
TEMPLATE_DIR=templates

.PHONY: process_template

$(TEMPLATE_DIR)/stack.json:
	mkdir -p $(TEMPLATE_DIR)/
	cfndsl src/proxy_stack.rb | json_pp > templates/stack.json

create_stack: $(TEMPLATE_DIR)//stack.json
	aws cloudformation create-stack --stack-name=$(STACK_NAME) --region $(REGION) \
	    --template-body file://$(PWD)/$(TEMPLATE_DIR)/stack.json | tee stacks/$(STACK_NAME).json

update_stack: $(TEMPLATE_DIR)/stack.json
	aws cloudformation update-stack --stack-name=$(STACK_NAME) --region $(REGION) \
		--template-body file://$(PWD)/$(TEMPLATE_DIR)/stack.json | tee stacks/$(STACK_NAME).json

delete_stack:
	aws cloudformation delete-stack --stack-name=$(STACK_NAME) --region $(REGION)

clean:
	rm -rf $(TEMPLATE_DIR)/*