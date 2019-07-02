#!/bin/bash

set -v
cd /home/appuser/
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
sudo cp /home/appuser/puma.service /etc/systemd/system/puma.service
systemctl daemon-reload
systemctl status puma
systemctl start puma
systemctl enable puma

