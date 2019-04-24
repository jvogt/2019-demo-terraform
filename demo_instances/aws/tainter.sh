#!/bin/bash

a=$(cat terraform.tfstate | jq -r ".modules[0].resources | with_entries(select(.key|match(\"aws_instance.$1\";\"i\"))) | keys | join(\" \")")
for rn in $a; do
  terraform taint $rn
done