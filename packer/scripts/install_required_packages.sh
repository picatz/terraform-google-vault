#!/bin/bash

set -ex

# https://github.com/hashicorp/packer/issues/2639
timeout 180 /usr/bin/cloud-init status --wait

sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    unzip \
    curl \
    gnupg-agent \
    libcap2-bin \
    software-properties-common \
    jq