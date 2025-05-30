#!/bin/bash

AMII_ID = "ami-09c813fb71547fc4f"
SG_ID = "sg-0230080558d89d483"
INSTANCES = ("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID = "Z10047623KH0C3QSAEKUQ"
DOMAIN_NAME = "busy98.site.com"

for instance in ${INSTANCES[@]}
do
   INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t2.micro --security-group-ids sg-0230080558d89d483 --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=test}]'
  --query 'Instances[0].InstanceId' --output text)
if[instance != "frontend"]
then
    IP = aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 
    'Reservations[0].Instances[*].PrivateIpAddress' --output text
else
     IP = aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 
    'Reservations[0].Instances[*].PublicIpAddress' --output text    
fi
    echo  "$instanceid IP Addredd $IP"
done

