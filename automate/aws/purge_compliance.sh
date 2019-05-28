#!/bin/bash

a=$(terraform state pull | jq -r ".modules[0].resources | with_entries(select(.key|match(\"aws_instance.chef_automate\";\"i\")))[] | .primary.attributes.public_ip")
ssh ubuntu@$a 'sudo curl -s http://localhost:10141/_cat/indices/comp*?h=i | while read compliance_index; do curl -X DELETE http://localhost:10141/$compliance_index; done; sudo chef-automate restart-services'
