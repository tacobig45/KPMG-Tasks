import boto3
ec2 = boto3.resource('ec2')
response = ec2.create_key_pair(KeyName='KeyPair1')
instances = ec2.create_instances(
        ImageId="ami-0cff7528ff583bf9a",
        MinCount=1,
        MaxCount=1,
        InstanceType="t2.micro",
        KeyName="KeyPair1"
)   