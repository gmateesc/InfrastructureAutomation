#!/bin/bash

# Wrapper for running the playbook

ansible-playbook   -i localhost,  update_java_elasticsearch.yml

