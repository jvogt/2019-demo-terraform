#!/bin/bash
export ANALYTICS_COMPANY_NAME=""
export ANALYTICS_ENABLED=false
export APP_SSL_ENABLED=true
export APP_URL=https://${habitat_depot_hostname}
export BLDR_CHANNEL=on-prem-stable
export BLDR_ORIGIN=habitat
export HAB_BLDR_URL=https://bldr.habitat.sh
export MINIO_ACCESS_KEY=depot
export MINIO_BUCKET=habitat-builder-artifact-store.local
export MINIO_ENDPOINT=http://localhost:9000
export MINIO_SECRET_KEY=password
export OAUTH_AUTHORIZE_URL=${habitat_oauth_authorize_url}
export OAUTH_CLIENT_ID=${habitat_oauth_client_id}
export OAUTH_CLIENT_SECRET=${habitat_oauth_client_secret}
export OAUTH_PROVIDER=${habitat_oauth_provider}
export OAUTH_REDIRECT_URL=https://${habitat_depot_hostname}/
export OAUTH_SIGNUP_URL=${habitat_oauth_signup_url}
export OAUTH_TOKEN_URL=${habitat_oauth_token_url}
export OAUTH_USERINFO_URL=${habitat_oauth_userinfo_url}

# export AUTOMATE_DOMAIN=https://jv-a2.chef-demo.com
# export OAUTH_AUTHORIZE_URL=$AUTOMATE_DOMAIN/session/new
# export OAUTH_CLIENT_ID=0123456789abcdef0123
# export OAUTH_CLIENT_SECRET=0123456789abcdef0123456789abcdef01234567
# export OAUTH_PROVIDER=chef-automate
# export OAUTH_REDIRECT_URL=https://${habitat_depot_hostname}/
# export OAUTH_SIGNUP_URL=$AUTOMATE_DOMAIN
# export OAUTH_TOKEN_URL=$AUTOMATE_DOMAIN/session/token
# export OAUTH_USERINFO_URL=$AUTOMATE_DOMAIN/session/userinfo

export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432