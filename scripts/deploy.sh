  #!/bin/bash
  set -e

  APP_DIR="/opt/todowebapi"
  APP_USER="appuser"
  S3_BUCKET="todo-webapi-app-6f0571ee"

  echo "=== [1/6] Update system ==="
  apt-get update -y && apt-get upgrade -y

  echo "=== [2/6] Install dependencies ==="
  apt-get install -y awscli unzip curl mysql-client

  # Install .NET 8 runtime
  wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb
  dpkg -i packages-microsoft-prod.deb
  apt-get update -y
  apt-get install -y aspnetcore-runtime-8.0

  # Install nginx
  apt-get install -y nginx

  # Install CloudWatch Agent
  wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
  dpkg -i amazon-cloudwatch-agent.deb

  echo "=== [3/6] Buat user aplikasi ==="
  useradd -r -m -s /bin/false $APP_USER || true
  mkdir -p $APP_DIR
  chown $APP_USER:$APP_USER $APP_DIR

  echo "=== [4/6] Copy app dari S3 ==="
  aws s3 cp s3://$S3_BUCKET/app.zip /tmp/app.zip
  unzip -o /tmp/app.zip -d $APP_DIR
  chown -R $APP_USER:$APP_USER $APP_DIR
  chmod +x $APP_DIR/TodoWebAPI

  echo "=== [5/6] Setup nginx ==="
  cat > /etc/nginx/sites-available/todowebapi << 'NGINXEOF'
  server {
      listen 80;
      server_name _;
      location / {
          proxy_pass         http://127.0.0.1:5000;
          proxy_http_version 1.1;
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP $remote_addr;
          proxy_cache_bypass $http_upgrade;
      }
  }
  NGINXEOF
  ln -sf /etc/nginx/sites-available/todowebapi /etc/nginx/sites-enabled/
  rm -f /etc/nginx/sites-enabled/default
  nginx -t && systemctl restart nginx

  echo "=== [6/6] Setup systemd & start app ==="
  mkdir -p /var/log/todowebapi
  chown $APP_USER:$APP_USER /var/log/todowebapi

  cat > /etc/systemd/system/todowebapi.service << SVCEOF
  [Unit]
  Description=Todo WebAPI .NET App
  After=network.target

  [Service]
  WorkingDirectory=$APP_DIR
  ExecStart=$APP_DIR/TodoWebAPI
  Restart=always
  RestartSec=10
  User=$APP_USER
  Environment=ASPNETCORE_ENVIRONMENT=Production
  StandardOutput=append:/var/log/todowebapi/app.log
  StandardError=append:/var/log/todowebapi/app.log

  [Install]
  WantedBy=multi-user.target
  SVCEOF

  systemctl daemon-reload
  systemctl enable todowebapi
  systemctl start todowebapi

  echo "=== DONE ==="
  echo "Swagger: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)/api-docs"
