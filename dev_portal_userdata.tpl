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
  - postgresql
runcmd:
  - [tailscale, up, -authkey, ${tailscale_auth_key}, -hostname, ${hostname}]
  - mkdir /etc/ssl/nginx
  - aws secretsmanager get-secret-value --secret-id ${nginx-repo-crt} --region ${region} --query 'SecretString' --output text > /etc/ssl/nginx/nginx-repo.crt
  - aws secretsmanager get-secret-value --secret-id ${nginx-repo-key} --region ${region} --query 'SecretString' --output text > /etc/ssl/nginx/nginx-repo.key
  - apt-get install -y apt-transport-https lsb-release ca-certificates wget gnupg2 ubuntu-keyring
  - wget -qO - https://cs.nginx.com/static/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
  - wget -qO - https://cs.nginx.com/static/keys/app-protect-security-updates.key | gpg --dearmor | sudo tee /usr/share/keyrings/app-protect-security-updates.gpg >/dev/null
  - printf "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://pkgs.nginx.com/plus/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nginx-plus.list
  - printf "deb https://pkgs.nginx.com/nms/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nms.list
  - wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90pkgs-nginx
  - apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62
  - apt-get update && apt-get install -y nginx-plus nginx-devportal nginx-devportal-ui nginx-plus-module-njs
  - systemctl start nginx
  - hostnamectl set-hostname ${hostname}
  - |
    cat << EOF | tee /etc/postgresql/12/main/pg_hba.conf

    # TYPE DATABASE USER ADDRESS METHOD
    
    local all postgres peer
    local all all md5
    # IPv4 local connections:
    host all all 127.0.0.1/32 md5
    # IPv6 local connections:
    host all all ::1/128 md5
    EOF
  - systemctl restart postgresql
  - sudo -u postgres createdb devportal
  - sudo -u postgres psql -c "CREATE USER nginxdm WITH LOGIN PASSWORD 'nginxdm';"
  - sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE devportal TO nginxdm;"
  - sed -i '1 s/^/load_module modules\/ngx_http_js_module.so;\nload_module modules\/ngx_stream_js_module.so;\n/' /etc/nginx/nginx.conf
  - systemctl start nginx-devportal
