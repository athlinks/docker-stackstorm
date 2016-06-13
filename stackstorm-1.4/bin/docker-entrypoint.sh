#!/bin/bash

api_url="${ST2_API_URL:-http://api:9101}"
auth_url="${ST2_AUTH_URL:-http://auth:9100}"
rmq_host="${ST2_RMQ_HOST:-rabbitmq}"
rmq_port="${ST2_RMQ_PORT:-5672}"
rmq_user="${ST2_RMQ_USER:-guest}"
rmq_pass="${ST2_RMQ_PASS:-guest}"
db_host="${ST2_DB_HOST:-mongodb}"
db_port="${ST2_DB_PORT:-27017}"
db_name="${ST2_DB_NAME:-st2}"
db_username="${ST2_DB_USERNAME:-None}"
db_password="${ST2_DB_PASSWORD:-None}"

amqp_url="amqp://$rmq_user:$rmq_pass@$rmq_host:$rmq_port/"

# Generate config file
generate_config_files() {
  cat /tmp/st2.conf.template | \
    sed -e "s|\$\$api_url|$api_url|" \
        -e "s|\$\$db_host|$db_host|" \
        -e "s|\$\$db_port|$db_port|" \
        -e "s|\$\$db_name|$db_name|" \
        -e "s|\$\$db_username|$db_username|" \
        -e "s|\$\$db_password|$db_password|" \
        -e "s|\$\$amqp_url|$amqp_url|" > /etc/st2/st2.conf

  cat /tmp/config.js.template | \
    sed -e "s|\$\$api_url|$api_url|" \
        -e "s|\$\$auth_url|$auth_url|" > /opt/stackstorm/static/webui/config.js
}

generate_config_files

if [ -z $ST2_SERVICE ]; then
  echo "SET THE ST2_SERVICE ENVIRONMENT VARIABLE"
  exit 1
fi

if [ "$ST2_SERVICE" = "st2web" ]; then
  /usr/sbin/nginx
else
  /opt/stackstorm/st2/bin/$ST2_SERVICE --config-file /etc/st2/st2.conf $@
fi
