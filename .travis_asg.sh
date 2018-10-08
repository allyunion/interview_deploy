#!/bin/bash

ORIGINAL_INSTANCE=$(aws elb describe-instance-health --load-balancer-name interview-webapp-elb --query InstanceStates[*].InstanceId --output text | head -n 1)
aws autoscaling update-auto-scaling-group --auto-scaling-group-name interview-webapp-asg --max-size 2 --desired-capacity 2

while [ "$(aws elb describe-instance-health --load-balancer-name interview-webapp-elb --query InstanceStates[*].InstanceId --output text | wc -l)" -lt "2" ];
do
  echo "Waiting for other instance to be healthy, sleeping 1 minute..."
  sleep 1m
done

aws autoscaling terminate-instance-in-auto-scaling-group --instance-id ${ORIGINAL_INSTANCE} --should-decrement-desired-capacity
