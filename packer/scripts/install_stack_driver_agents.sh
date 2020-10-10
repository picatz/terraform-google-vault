#!/bin/bash

set -ex

# Install Stackdriver for logging and monitoring
curl -sSfL https://dl.google.com/cloudagents/install-logging-agent.sh | sudo bash
curl -sSfL https://dl.google.com/cloudagents/install-monitoring-agent.sh | sudo bash