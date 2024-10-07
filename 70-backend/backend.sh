#!/bin/bash

component=$1
environment=$2
echo "Component: $component, Environment: $environment" 
dnf install ansible -y 
ansible-pull -i localhost, -U https://github.com/santhan29/expense-ansible-roles-tf1.git main.yaml -e component=$component -e environment=$environment 