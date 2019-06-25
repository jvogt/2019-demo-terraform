#!/bin/bash

sed -i 's/ExecStart/Environment=HAB_FEAT_EVENT_STREAM=1\nExecStart/g' /etc/systemd/system/hab-supervisor.service
sed -i 's/unstable/unstable --event-stream-application=${app} --event-stream-environment=${env} --event-stream-site=aws --event-stream-url=${automate_hostname}:4222 --event-stream-token=${automate_api_token}/g' /etc/systemd/system/hab-supervisor.service
systemctl daemon-reload
service hab-supervisor restart

