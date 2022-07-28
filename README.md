# NGINX Management Suite Lab

This repository will build out a 3 server deployment allowing the user to configure the NGINX Management Suite, Developer Portal, and API Gateway instances.

This deployment leverages Tailscale to connect into the EC2 instances.

## Configure NMS

Once the NMS server is up and running, you will need to reset the NMS admin password:

```bash
sudo htpasswd -c /etc/nms/nginx/.htpasswd admin
```

Next, you will need to login to the NMS UI and [add a license](https://docs.nginx.com/nginx-management-suite/admin-guides/getting-started/add-license/).
