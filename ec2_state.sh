#!/bin/bash

GetEC2Instances()
{
    echo $(aws ec2 describe-instances --filters Name=instance-state-name,Values=running Name=tag:Project,Values=cody-nms --query "Reservations[*].Instances[*].InstanceId" --output text)
}

Start()
{
    echo "Starting EC2 instances"
    for i in $(GetEC2Instances); 
    do 
        echo "Starting $i";
        aws ec2 start-instances --instance-ids $i;
    done
}

Stop()
{
    echo "Stopping EC2 instances"
    for i in $(GetEC2Instances); 
    do
        echo "Stopping $i";
        aws ec2 stop-instances --instance-ids $i;
    done
}

Help()
{
    # Display Help
    echo "Change the state of the running EC2 instances"
    echo
    echo "Syntax: ec2_state.sh [s|t]"
    echo "options:"
    echo "s     Start EC2 instances"
    echo "t     Stop EC2 instances"
    echo
}

# Read input argument

while getopts ":hst" option; do
    case $option in
        h) # display Help
            Help
            exit;;
        s) # start EC2 instances
            Start
            exit;;
        t) # stop EC2 instances
            Stop
            exit;;
        \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
    esac
done

# find EC2 instances
# instances=`aws ec2 describe-instances --filters Name=instance-state-name,Values=running Name=tag:Project,Values=cody-nms --query "Reservations[*].Instances[*].InstanceId" --output text`
# for i in $instances; 
# do
#     echo $i;
# done