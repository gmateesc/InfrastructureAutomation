#!/bin/bash

#hosts=webservers
hosts=$(egrep hosts playbook.yml  | awk '{print $2}')

ansible $hosts --list-hosts

