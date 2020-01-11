#!/bin/bash
set -e

#install Ruby and Bundler
apt update -y
apt upgrade -y
apt install -y ruby-full ruby-bundler build-essential
