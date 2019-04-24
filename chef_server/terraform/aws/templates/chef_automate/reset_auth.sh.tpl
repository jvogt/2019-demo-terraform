export TOK=`chef-automate admin-token`

curl -X POST \
  https://localhost/api/v0/auth/tokens \
  --insecure \
  -H "api-token: $TOK" \
  -d '{"value": "terraform-created-demo-token","description": "From Terraform","active": true, "id": "00000000-0000-0000-0000-000000000000"}'

curl -s \
  https://localhost/api/v0/auth/policies \
  --insecure \
  -H "api-token: $TOK" \
  -H "Content-Type: application/json" \
  -d '{"subjects":["token:00000000-0000-0000-0000-000000000000"], "action":"read", "resource":"compliance:*"}'

chef-automate iam admin-access restore automate-demo
