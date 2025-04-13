#!/usr/bin/env bash

project_name=$1
node_name=$(epmd -names | grep project-"$project_name" | awk '{print $2}')

iex --name "shell@127.0.0.1" \
    --remsh "${node_name}" \
    --cookie lexical