#!/bin/sh
echo "Creating Json Output and redirecting to output.json"
aws ec2 describe-instances > output.json
echo

echo "Sending Metadata information into Text file in Tabular Format"
aws ec2 describe-instances --output table > Tabularoutput
echo

echo "Sending Filtered output (based on Instance type) into Text file"
aws ec2 describe-instances --filters "Name=instance-type,Values=t2.micro" --query "Reservations[].Instances[].InstanceId" > filteredoutput
echo

echo "Files created : Tabularoutput, output.json and filteredoutput"
echo "Task Completed"