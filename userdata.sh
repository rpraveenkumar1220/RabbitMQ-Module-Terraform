#!/bin/bash

sudo labauto ansible
ansible-pull -i localhost, -U https://github.com/rpraveenkumar1220/Roboshop-Ansible.git  roboshop.yml -e env=${var.env} -e role_name=rabbitmq &>> /opt/ansible.log
