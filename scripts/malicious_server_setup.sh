#!/bin/bash
yum update -y
yum install -y python3

# Start simple HTTP server
nohup python3 -m http.server 80 &