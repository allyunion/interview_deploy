#!/bin/bash

ORIGINAL_INSTANCE=$(aws elb describe-instance-health --load-balancer-name interview-webapp-elb --query 'InstanceStates[*].[InstanceId, State]' --output text | grep InService | head -n 1 | awk '{print $1};')
echo "Current production instance is: ${ORIGINAL_INSTANCE}"
echo "Updating autoscaling group to desired capacity of 2..."
echo "$ aws autoscaling update-auto-scaling-group --auto-scaling-group-name interview-webapp-asg --max-size 2 --desired-capacity 2"
aws autoscaling update-auto-scaling-group --auto-scaling-group-name interview-webapp-asg --max-size 2 --desired-capacity 2

echo "Entering waiting loop..."
while [ "$(aws elb describe-instance-health --load-balancer-name interview-webapp-elb --query 'InstanceStates[*].[InstanceId, State]' --output text | grep InService | awk '{print $1};' | wc -w)" -lt "2" ];
do
  echo "Waiting for other instance to be healthy, sleeping 5 seconds..."
  sleep 5
done
echo "Complete!"

echo "Terminating old instance..."
echo "$ aws autoscaling terminate-instance-in-auto-scaling-group --instance-id ${ORIGINAL_INSTANCE} --should-decrement-desired-capacity"
aws autoscaling terminate-instance-in-auto-scaling-group --instance-id ${ORIGINAL_INSTANCE} --should-decrement-desired-capacity

echo "Current production instance is: $(aws elb describe-instance-health --load-balancer-name interview-webapp-elb --query 'InstanceStates[*].[InstanceId, State]' --output text | grep InService | head -n 1 | awk '{print $1};')"

