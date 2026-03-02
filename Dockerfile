FROM alpine:latest

# 安装依赖
RUN apk add --no-cache ca-certificates curl postgresql-client gettext supervisor unzip

# 下载官方编译好的二进制（amd64版本）
RUN curl -L -o /tmp/nezha.zip \
    https://github.com/nezhahq/nezha/releases/latest/download/dashboard-linux-amd64.zip && \
    unzip /tmp/nezha.zip -d /dashboard && \
    chmod +x /dashboard/dashboard-linux-amd64 && \
    ln -s /dashboard/dashboard-linux-amd64 /dashboard/nezha-dashboard && \
    rm /tmp/nezha.zip

# 下载 cloudflared
RUN curl -L -o /usr/local/bin/cloudflared \
    https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && \
    chmod +x /usr/local/bin/cloudflared

# 创建 choreo 用户
RUN adduser -D -u 10001 choreo && \
    mkdir -p /data /var/log/supervisor /var/run /etc/supervisor/conf.d && \
    chown -R choreo:choreo /data /var/log/supervisor /var/run /etc/supervisor

# 复制配置文件
COPY --chown=choreo:choreo config.yaml.template /data/
COPY --chown=choreo:choreo start.sh /start.sh
COPY --chown=choreo:choreo supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN chmod +x /start.sh

USER 10001
WORKDIR /dashboard

EXPOSE 8008

CMD ["/start.sh"]
