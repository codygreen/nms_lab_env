#cloud-config
---
update_hostname: ${hostname}
package_update: true
package_upgrade: true
apt:
  sources:
    tailscale.list:
      source: deb https://pkgs.tailscale.com/stable/ubuntu focal main
      keyid: 2596A99EAAB33821893C0A79458CA832957F5868
packages: 
  - tailscale
  - awscli
  - apache2-utils
runcmd:
  - [tailscale, up, -authkey, ${tailscale_auth_key}, -hostname, ${hostname}]
  - mkdir /etc/ssl/nginx
  - aws secretsmanager get-secret-value --secret-id ${nginx-repo-crt} --region ${region} --query 'SecretString' --output text > /etc/ssl/nginx/nginx-repo.crt
  - aws secretsmanager get-secret-value --secret-id ${nginx-repo-key} --region ${region} --query 'SecretString' --output text > /etc/ssl/nginx/nginx-repo.key
  - aws secretsmanager get-secret-value --secret-id ${nms-license} --region ${region} --query 'SecretString' --output text > ${nms-license-file}
  - apt-get install -y apt-transport-https lsb-release ca-certificates wget gnupg2 ubuntu-keyring dirmngr
  - wget -qO - https://cs.nginx.com/static/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
  - wget -qO - https://cs.nginx.com/static/keys/app-protect-security-updates.key | gpg --dearmor | sudo tee /usr/share/keyrings/app-protect-security-updates.gpg >/dev/null
  - printf "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://pkgs.nginx.com/plus/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nginx-plus.list
  - printf "deb https://pkgs.nginx.com/nms/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nms.list
  - wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90pkgs-nginx
  - echo "deb https://packages.clickhouse.com/deb stable main" | sudo tee /etc/apt/sources.list.d/clickhouse.list
  - apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62
  - apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8919F6BD2B48D75
  - apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8919F6BD2B48D754
  - apt-get update && apt-get install -y nginx-plus
  - DEBIAN_FRONTEND=noninteractive apt-get install -y clickhouse-server clickhouse-client
  - apt-get install -y nms-instance-manager
  - systemctl enable clickhouse-server
  - systemctl enable nms
  - systemctl enable nms-core
  - systemctl enable nms-dpm
  - systemctl enable nms-ingestion
  - systemctl enable nms-integrations
  - systemctl start nms
  - systemctl start nms-core
  - systemctl start nms-dpmnms-
  - systemctl start nms-ingestion
  - systemctl start nms-integrations
  - systemctl restart nginx
  - apt-get install -y nms-api-connectivity-manager nms-sm
  - systemctl enable nms-acm
  - systemctl restart nms
  - systemctl restart nms-core
  - systemctl restart nms-dpm
  - systemctl restart nms-ingestion
  - systemctl restart nms-integrations
  - systemctl restart nginx
  - hostnamectl set-hostname ${hostname}
  - htpasswd -b -c /etc/nms/nginx/.htpasswd ${nms-admin-username} ${nms-admin-password}
  - 'curl -k --location --request PUT "https://${nms-host}/api/platform/v1/license" --header "Authorization: Basic `printf "%s:%s" "${nms-admin-username}" "${nms-admin-password}" | base64`" --header "Content-Type: application/json" --data-raw "{ \"desiredState\": { \"content\": \"`cat ${nms-license-file}`\" }, \"metadata\": { \"name\": \"license\" } }"'
  - rm ${nms-license-file}
