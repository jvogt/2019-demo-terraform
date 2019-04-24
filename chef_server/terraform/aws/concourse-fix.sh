sudo hab file upload concourse-web.default $(date +%s) ~/keys/web/session_signing_key
sudo hab file upload concourse-web.default $(date +%s) ~/keys/web/session_signing_key.pub
sudo hab file upload concourse-web.default $(date +%s) ~/keys/web/tsa_host_key
sudo hab file upload concourse-web.default $(date +%s) ~/keys/web/tsa_host_key.pub
sudo hab file upload concourse-worker.default $(date +%s) ~/keys/worker/worker_key.pub
sudo hab file upload concourse-worker.default $(date +%s) ~/keys/worker/worker_key
sudo hab file upload concourse-worker.default $(date +%s) ~/keys/worker/tsa_host_key.pub
sudo hab stop habitat/concourse-web
sudo hab start habitat/concourse-web