#!/bin/bash
sudo hostnamectl set-hostname ${automate_hostname}
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w vm.dirty_expire_centisecs=20000

which unzip >/dev/null 2>&1
if [[ $? != 0 ]]; then
  cat /etc/os-release |grep -i centos >/dev/null
  if [[ $? != 0 ]]; then
    yum install -y unzip
  fi
  cat /etc/os-release |grep -i ubuntu >/dev/null
  if [[ $? != 0 ]]; then
    apt-get install -y unzip
  fi
fi

pushd "/tmp"
  curl https://packages.chef.io/files/current/automate/latest/chef-automate_linux_amd64.zip |gunzip - > chef-automate && chmod +x chef-automate
  mv chef-automate /usr/sbin/chef-automate
  mkdir -p /etc/chef-automate
popd

chef-automate init-config --file /tmp/config.toml
sed -i 's/fqdn = \".*\"/fqdn = \"${automate_hostname}\"/g' /tmp/config.toml
sed -i 's/channel = \".*\"/channel = \"${channel}\"/g' /tmp/config.toml
sed -i 's/license = \".*\"/license = \"${automate_license}\"/g' /tmp/config.toml
rm -f /tmp/ssl_cert /tmp/ssl_key
mv /tmp/config.toml /etc/chef-automate/config.toml
chef-automate deploy /etc/chef-automate/config.toml --accept-terms-and-mlsa

export TOK=`chef-automate admin-token`

curl -X POST \
  https://localhost/api/v0/auth/tokens \
  --insecure \
  -H "api-token: $TOK" \
  -d '{"value": "${compliance_api_token}","description": "From Terraform","active": true, "id": "00000000-0000-0000-0000-000000000000"}'

curl -s \
  https://localhost/api/v0/auth/policies \
  --insecure \
  -H "api-token: $TOK" \
  -H "Content-Type: application/json" \
  -d '{"subjects":["token:00000000-0000-0000-0000-000000000000"], "action":"read", "resource":"compliance:*"}'

chef-automate iam admin-access restore "${a2_admin_password}"

