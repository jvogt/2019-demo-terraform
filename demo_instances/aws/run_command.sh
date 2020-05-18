#!/bin/bash

for ip in $(./get_instances.sh $1); do
  ssh -o "StrictHostKeyChecking=no" centos@$ip $2 &
done

# for ip in $(./get_instances.sh $1); do
#   knife bootstrap centos@$ip -N $ip --policy_name base --policy_group $1 -y -i ~/Desktop/jvogt-sa-aws.pem --sudo &
# done