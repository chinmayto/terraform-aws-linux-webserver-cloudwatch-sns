# Linux Web Server in AWS using Terraform with a cloudwatch alarm and SNS for email alert.

Deploying Linux Web Server EC2 Instance in AWS using Terraform with a cloudwatch alarm and SNS for email alert

![Alt text](/images/diagram.png)

1. vpc module - to create vpc, public subnets, internet gateway, security groups and route tables
2. web module - to create Linux Web EC2 instances with userdata script to display instance metadata using latest Amazon Linux ami in multiple subnets created in vpc module
3. main module - Above modules get called in main config. Create a SNS topic, its subscription and cloudwatch alarm metric

# Other notes
1. Metric somtimes goes to "INSUFFICIENT_DATA" state because of multiple reasons. Refer to https://repost.aws/knowledge-center/cloudwatch-alarm-insufficient-data-state

Missing monitoring data is treated as good using "treat_missing_data" param

2. For explanation purpose, detailed monitoring is enabled for EC2 instances for monitoring every 1 minute using "monitoring" param. This will incur more charges.

Terraform Apply Output: 
```
Apply complete! Resources: 14 added, 0 changed, 0 destroyed.

Outputs:

ec2_instance_ids = [
  "i-0cb970e939f9d79d8",
  "i-0b13793c64a5b3b9c",
]
public_subnets = [
  "subnet-068ae3976e9d5e2a7",
  "subnet-0427b8c72b666af01",
]
security_groups_ec2 = [
  "sg-0b6f4b4ce448ff583",
]
```
SNS topic created:

![Alt text](/images/snstopic.png)

Subscription confirmation:

![Alt text](/images/sub1.png)

![Alt text](/images/sub2.png)

Running EC2 instances:

![Alt text](/images/ec2list.png)

Cloudwatch Alarms:

![Alt text](/images/cwalarm1.png)

![Alt text](/images/cwalarm2.png)

Stressing first EC2:
We need to install stress package:
```
 amazon-linux-extras install epel -y
 yum install stress -y
 stress -c 1 --backoff 300000000 -t 30m
```

![Alt text](/images/stressa1.png)

![Alt text](/images/stressa2.png)

![Alt text](/images/stressa3.png)

Stressing second EC2:

![Alt text](/images/stressb1.png)

![Alt text](/images/stressb2.png)

![Alt text](/images/stressb3.png)

Both instances in alarm state:

![Alt text](/images/alarm1.png)

![Alt text](/images/alarm2.png)


Terraform Destroy Output:
```
Destroy complete! Resources: 14 destroyed.
```