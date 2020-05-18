#!/bin/bash
echo "Prepping for Automate Installation"
hostnamectl set-hostname ${automate_hostname}
sysctl -w vm.max_map_count=262144
sysctl -w vm.dirty_expire_centisecs=20000

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

echo "Downloading Chef Automate CLI tool"
pushd "/tmp"
  curl https://packages.chef.io/files/current/automate/latest/chef-automate_linux_amd64.zip |gunzip - > chef-automate && chmod +x chef-automate
  mv chef-automate /usr/sbin/chef-automate
  mkdir -p /etc/chef-automate
popd

echo "Initializing Config"
chef-automate init-config --file /tmp/config.toml
sed -i 's/fqdn = \".*\"/fqdn = \"${automate_hostname}\"/g' /tmp/config.toml
sed -i 's/channel = \".*\"/channel = \"${channel}\"/g' /tmp/config.toml
sed -i 's/license = \".*\"/license = \"${automate_license}\"/g' /tmp/config.toml
rm -f /tmp/ssl_cert /tmp/ssl_key

mkdir -p /etc/chef-automate
cp /tmp/config.toml /etc/chef-automate/config.toml

echo "Installing Chef Automate"
chef-automate deploy /etc/chef-automate/config.toml --accept-terms-and-mlsa

echo "Adding hardcoded api token"
if [[ "$(chef-automate iam version)" = "IAM v2."* ]]
then
  export TOK=`chef-automate iam token create demo --admin`
  echo version 2.x!
fi

if [ "$(sudo chef-automate iam version)" = 'IAM v1.0' ]
then
  export TOK=`chef-automate admin-token`
  echo version 1.0!
fi

echo "ADMIN_TOKEN=$TOK"
curl -X POST \
  https://localhost/apis/iam/v2/tokens \
  --insecure \
  -H "api-token: $TOK" \
  -d '{"name":"demo-token","value": "${compliance_api_token}","description": "From Terraform","active": true, "id": "demo-token"}'

curl -s \
  https://localhost/apis/iam/v2/policies/administrator-access/members:add \
  --insecure \
  -H "api-token: $TOK" \
  -H "Content-Type: application/json" \
  -d '{"members":["token:demo-token"]}'


echo "Resetting Admin Password"
chef-automate iam admin-access restore "${a2_admin_password}"


echo "Preloading Profiles"
snap install jq
RESULTS=$(curl -X POST \
  https://localhost/api/v0/compliance/profiles/search \
  --insecure \
  -H "api-token: $TOK")

PROFILES="${preload_profiles}"

for NAME in $PROFILES; do
  VERSION=$(echo "$RESULTS" | jq -r "[.profiles[] | {name, version}| select(.name == \"$NAME\")][0] | .version")
  PAYLOAD="{\"name\": \"$NAME\", \"version\": \"$VERSION\"}"
  curl -X POST \
  --insecure \
  'https://localhost/api/v0/compliance/profiles?owner=admin' \
  -H 'Content-Type: application/json' \
  -H "api-token: $TOK" \
  -d "$PAYLOAD"
done

echo "Enabling EAS"

echo "Patching TLS config for EAS"
echo "[event_gateway]
        [event_gateway.v1]
          [event_gateway.v1.sys]
            [event_gateway.v1.sys.service]
              disable_frontend_tls = true" >> /tmp/easpatch.toml

chef-automate config patch /tmp/easpatch.toml

sleep 30

echo "Enabling EAS"
chef-automate applications enable

sleep 30

# echo "Subscribing to Acceptance Channel"
# echo "[deployment.v1]
#         [deployment.v1.svc]
#           # Habitat channel to install hartifact from.
#           # Can be 'dev', 'current', or 'acceptance'
#           channel = \"acceptance\"" >> /tmp/acceptance.toml

# chef-automate config patch /tmp/acceptance.toml

echo "Done"
