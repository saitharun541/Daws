#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0230080558d89d483"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z10047623KH0C3QSAEKUQ"
DOMAIN_NAME="busy98.site.com"

for instance in "${INSTANCES[@]}"
do
   INSTANCE_ID=$(aws ec2 run-instances \
       --image-id "ami-09c813fb71547fc4f" \
       --instance-type t2.micro \
       --security-group-ids "sg-0230080558d89d483" \
       --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=test}]" \
       --query 'Instances[0].InstanceId' \
       --output text)

   if [ "$instance" != "frontend" ]; then
       IP=$(aws ec2 describe-instances \
           --instance-ids "$INSTANCE_ID" \
           --query 'Reservations[0].Instances[0].PrivateIpAddress' \
           --output text)
   else
       IP=$(aws ec2 describe-instances \
           --instance-ids "$INSTANCE_ID" \
           --query 'Reservations[0].Instances[0].PublicIpAddress' \
           --output text)
   fi

   echo "$instance ($INSTANCE_ID) IP Address: $IP"
   aws route53 change-resource-record-sets \
  --hosted-zone-id "$ZONE_ID" \
  --change-batch "$(cat <<EOF
{
  "Comment": "Creating record for $instance.$DOMAIN_NAME",
  "Changes": [{
    "Action": "CREATE",
    "ResourceRecordSet": {
      "Name": "$instance.$DOMAIN_NAME",
      "Type": "A",
      "TTL": 60,
      "ResourceRecords": [{
        "Value": "$IP"
      }]
    }
  }]
}
EOF
)"

done
