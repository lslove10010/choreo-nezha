FROM alpine:latest

USER root

# 安装必要工具
RUN apk add --no-cache ca-certificates curl postgresql-client gettext

# 下载哪吒面板官方二进制（amd64）
RUN curl -L -o /tmp/nezha.zip \
    https://github.com/nezhahq/nezha/releases/latest/download/dashboard-linux-amd64.zip && \
    unzip /tmp/nezha.zip -d /tmp && \
    mv /tmp/dashboard-linux-amd64 /dashboard/nezha-dashboard && \
    chmod +x /dashboard/nezha-dashboard && \
    rm -rf /tmp/nezha.zip /tmp/dashboard-*

# 下载 cloudflared
RUN curl -L -o /usr/local/bin/cloudflared \
    https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && \
    chmod +x /usr/local/bin/cloudflared

# 创建 choreo 用户（UID 10001）
RUN adduser -D -u 10001 choreo && \
    mkdir -p /data /tmp && \
    chown -R choreo:choreo /data /tmp /dashboard

# 复制配置文件
COPY --chown=choreo:choreo config.yaml.template /data/
COPY --chown=choreo:choreo start.sh /start.sh

RUN chmod +x /start.sh

# 切换到非 root 用户（Choreo 强制要求）
USER 10001
WORKDIR /dashboard

EXPOSE 8008

CMD ["/start.sh"]
