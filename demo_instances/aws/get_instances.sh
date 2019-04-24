#!/bin/bash
cat terraform.tfstate | jq -r ".modules[0].resources | with_entries(select(.key|match(\"aws_instance.$1\";\"i\")))[] | .primary.attributes.public_ip"
