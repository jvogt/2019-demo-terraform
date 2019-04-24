ssh to concourse worker

sudo hab file upload concourse-worker.default $(date +%s) ~/keys/worker/worker_key.pub
sudo hab file upload concourse-worker.default $(date +%s) ~/keys/worker/worker_key
sudo hab file upload concourse-worker.default $(date +%s) ~/keys/worker/tsa_host_key.pub

then from desktop

fly --target demo login --concourse-url http://concourse-1cc58bbe-1193421205.us-west-2.elb.amazonaws.com -u admin -p aws123
fly --target demo sync

fly -t demo set-pipeline -p chef-code -c chef-pipeline.yml
fly -t demo set-pipeline -p app-code -c app-pipeline.yml