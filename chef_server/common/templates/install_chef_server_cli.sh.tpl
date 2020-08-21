#!/bin/bash

set -e

mkdir -p /etc/chef/accepted_licenses
touch /etc/chef/accepted_licenses/chef_infra_client
touch /etc/chef/accepted_licenses/chef_infra_server
touch /etc/chef/accepted_licenses/inspec

cd /tmp && wget https://packages.chef.io/files/current/chef-server/14.0.4/ubuntu/18.04/chef-server-core_14.0.4-1_amd64.deb
dpkg -i /tmp/chef-server-core_14.0.4-1_amd64.deb
chef-server-ctl reconfigure
chef-server-ctl user-create ${chef_username} ${chef_user} ${chef_user_email} ${chef_password} --filename /tmp/stack.pem

echo "${chef_user_public_key}" > /tmp/chefuser.pem
chef-server-ctl add-user-key ${chef_username} --public-key-path /tmp/chefuser.pem

chef-server-ctl org-create ${chef_organization_id} "${chef_organization_name}" --association_user ${chef_username} --filename /tmp/stack-validator.pem
mkdir -p /etc/opscode/
# chef-server-ctl install chef-manage
# chef-server-ctl reconfigure
# chef-manage-ctl reconfigure --accept-license
# chef-server-ctl install opscode-reporting
# chef-server-ctl reconfigure
# opscode-reporting-ctl reconfigure --accept-license
# chef-server-ctl reconfigure
echo "api_fqdn = \"${chef_server_hostname}\"" > /etc/opscode/chef-server.rb
echo "nginx[\"enable_non_ssl\"] = true" >> /etc/opscode/chef-server.rb
chef-server-ctl reconfigure
chef-server-ctl set-secret data_collector token '${compliance_api_token}'
chef-server-ctl restart nginx
chef-server-ctl restart opscode-erchef
echo "data_collector['root_url'] = 'https://${automate_hostname}/data-collector/v0/'" >> /etc/opscode/chef-server.rb
echo "data_collector['proxy'] = true" >> /etc/opscode/chef-server.rb
echo "profiles['root_url'] = 'https://${automate_hostname}'" >> /etc/opscode/chef-server.rb
echo "opscode_erchef['max_request_size'] = '100000000'" >> /etc/opscode/chef-server.rb
chef-server-ctl reconfigure

echo "Finished"
