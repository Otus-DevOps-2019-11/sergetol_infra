#!/bin/bash

#install Ruby and Bundler
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y ruby-full ruby-bundler build-essential

ruby -v
bundler -v
