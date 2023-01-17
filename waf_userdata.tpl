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
runcmd:
  - export DEBIAN_FRONTEND=noninteractive
  - [tailscale, up, -authkey, ${tailscale_auth_key}, -hostname, ${hostname}]
  - mkdir /etc/ssl/nginx
  - aws secretsmanager get-secret-value --secret-id ${nginx-repo-crt} --region ${region} --query 'SecretString' --output text > /etc/ssl/nginx/nginx-repo.crt
  - aws secretsmanager get-secret-value --secret-id ${nginx-repo-key} --region ${region} --query 'SecretString' --output text > /etc/ssl/nginx/nginx-repo.key
  - apt-get install -y apt-transport-https lsb-release ca-certificates wget gnupg2 ubuntu-keyring
  - wget -qO - https://cs.nginx.com/static/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
  - wget -qO - https://cs.nginx.com/static/keys/app-protect-security-updates.key | gpg --dearmor | sudo tee /usr/share/keyrings/app-protect-security-updates.gpg >/dev/null
  - printf "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://pkgs.nginx.com/plus/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nginx-plus.list
  - printf "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://pkgs.nginx.com/app-protect/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nginx-app-protect.list
  - printf "deb [signed-by=/usr/share/keyrings/app-protect-security-updates.gpg] https://pkgs.nginx.com/app-protect-security-updates/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee -a /etc/apt/sources.list.d/nginx-app-protect.list
  - wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90pkgs-nginx
  - apt-get update && apt-get install -y app-protect nginx-plus-module-njs
  - hostnamectl set-hostname ${hostname}
  - systemctl enable nginx
  - systemctl start nginx
  - curl -k https://${nms-host}/install/nginx-agent | sudo sh
  - systemctl enable nginx-agent
  - systemctl start nginx-agent
  - "sed -i 's~^config_dirs: \"/etc/nginx:/usr/local/etc/nginx:/usr/share/nginx/modules:/etc/nms\"$~config_dirs: \"/etc/nginx:/usr/local/etc/nginx:/usr/share/nginx/modules:/etc/nms:/etc/app_protect\"~' /etc/nginx-agent/nginx-agent.conf"
  - |
    cat << EOF | tee -a /etc/nginx-agent/nginx-agent.conf

    # Enable reporting NGINX App Protect details to the control plane.
    nginx_app_protect:
      # Report interval for NGINX App Protect details - the frequency the NGINX Agent checks NGINX App Protect for changes.
      report_interval: 15s
    
    # NGINX App Protect Monitoring config
    nap_monitoring:
      # Buffer size for collector. Will contain log lines and parsed log lines
      collector_buffer_size: 50000
      # Buffer size for processor. Will contain log lines and parsed log lines
      processor_buffer_size: 50000
      # Syslog server IP address the collector will be listening to
      syslog_ip: "127.0.0.1"
      # Syslog server port the collector will be listening to
      syslog_port: 514
    EOF
  - sed -i '1 s/^/load_module modules\/ngx_http_app_protect_module.so;\n/' /etc/nginx/nginx.conf
  - |
    cat << EOF | tee /etc/nginx/conf.d/api.conf
    server {
        listen 127.0.0.1:8080;
        location /api {
            api write=on;
            allow 127.0.0.1;
            deny all;
        }
    }
    EOF
  - |
    cat << EOF | tee /etc/app_protect/conf/log_sm.json
    {
        "filter": {
            "request_type": "illegal"
        },
        "content": {
            "format": "user-defined",
            "format_string": "%blocking_exception_reason%,%dest_port%,%ip_client%,%is_truncated_bool%,%method%,%policy_name%,%protocol%,%request_status%,%response_code%,%severity%,%sig_cves%,%sig_set_names%,%src_port%,%sub_violations%,%support_id%,%threat_campaign_names%,%violation_rating%,%vs_name%,%x_forwarded_for_header_value%,%outcome%,%outcome_reason%,%violations%,%violation_details%,%bot_signature_name%,%bot_category%,%bot_anomalies%,%enforced_bot_anomalies%,%client_class%,%client_application%,%client_application_version%,%transport_protocol%,%uri%,%request%",
            "max_request_size": "2048",
            "max_message_size": "5k",
            "list_delimiter": "::"
        }
    }
    EOF
  - sed -i '/server_name  localhost;/a \    status_zone default_server;\n    app_protect_enable on;\n    app_protect_security_log_enable on;\n    app_protect_security_log "\/etc\/app_protect\/conf\/log_sm.json" syslog:server=127.0.0.1:514;' /etc/nginx/conf.d/default.conf
  - systemctl restart nginx-agent
  - systemctl restart nginx
