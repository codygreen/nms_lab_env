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
  - [tailscale, up, -authkey, ${tailscale_auth_key}, -hostname, ${hostname}]
  - hostnamectl set-hostname ${hostname}
  - snap install helm --classic
  - curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --egress-selector-mode=disabled --bind-address 0.0.0.0 --kube-apiserver-arg=feature-gates=LegacyServiceAccountTokenNoAutoGeneration=false" sh -s -
  - helm repo add nginx-stable https://helm.nginx.com/stable
  - helm repo update
  - helm install my-release nginx-stable/nginx-ingress --kubeconfig=/etc/rancher/k3s/k3s.yaml
  - kubectl apply -f https://raw.githubusercontent.com/f5devcentral/modern_app_jumpstart_workshop/main/manifests/brewz/app.yaml
  - kubectl apply -f https://raw.githubusercontent.com/f5devcentral/modern_app_jumpstart_workshop/main/manifests/brewz/mongo-init.yaml
  - kubectl apply -f https://raw.githubusercontent.com/f5devcentral/modern_app_jumpstart_workshop/main/manifests/brewz/virtual-server.yaml
  