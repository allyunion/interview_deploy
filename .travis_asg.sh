#!/bin/bash

ORIGINAL_INSTANCE=$(aws elb describe-instance-health --load-balancer-name interview-webapp-elb --query InstanceStates[*].InstanceId --output text | head -n 1)
echo "Current production instance is: ${ORIGINAL_INSTANCE}"
echo "Updating autoscaling group to desired capacity of 2..."
echo "$ aws autoscaling update-auto-scaling-group --auto-scaling-group-name interview-webapp-asg --max-size 2 --desired-capacity 2"
aws autoscaling update-auto-scaling-group --auto-scaling-group-name interview-webapp-asg --max-size 2 --desired-capacity 2

echo "Entering waiting loop..."
while [ "$(aws elb describe-instance-health --load-balancer-name interview-webapp-elb --query InstanceStates[*].InstanceId --output text | wc -w)" -lt "2" ];
do
  echo "Waiting for other instance to be healthy, sleeping 1 minute..."
  sleep 1m
done
echo "Complete!"

echo "Terminating old instance..."
echo "$ aws autoscaling terminate-instance-in-auto-scaling-group --instance-id ${ORIGINAL_INSTANCE} --should-decrement-desired-capacity"
aws autoscaling terminate-instance-in-auto-scaling-group --instance-id ${ORIGINAL_INSTANCE} --should-decrement-desired-capacity

echo "Current production instance is: $(aws elb describe-instance-health --load-balancer-name interview-webapp-elb --query InstanceStates[*].InstanceId --output text)"

