#!/bin/bash
apt update -y
apt install nginx -y
rm -r /var/www/html/*
git clone https://github.com/ravi2krishna/login-2418.git /var/www/html/