#!/bin/bash

for ip in $(./get_instances.sh $1); do
  ssh -o "StrictHostKeyChecking=no" centos@$ip $2 &
done

