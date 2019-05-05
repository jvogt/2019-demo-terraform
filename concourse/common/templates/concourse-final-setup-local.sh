fly --target demo login --concourse-url http://${concourse_url} -u ${concourse_user_name} -p ${concourse_user_password}
fly --target demo sync
fly -t demo set-pipeline -p chef-code -c ../chef-pipeline.yml
fly -t demo set-pipeline -p app-code -c ../app-pipeline.yml
fly -t demo set-pipeline -p packer-code -c ../packer-pipeline.yml
