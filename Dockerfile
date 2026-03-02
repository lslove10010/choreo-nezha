# 构建阶段
FROM golang:1.24-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git make nodejs npm

# 克隆官方仓库
RUN git clone --depth 1 https://github.com/nezhahq/nezha.git .

# 构建前端
WORKDIR /app/dashboard
RUN npm install && npm run build

# 构建后端
WORKDIR /app
RUN go mod download
RUN CGO_ENABLED=1 go build -o nezha-dashboard ./cmd/dashboard

# 运行阶段
FROM alpine:latest

RUN apk add --no-cache ca-certificates curl postgresql-client gettext supervisor

# 安装 cloudflared
RUN curl -L -o /usr/local/bin/cloudflared \
    https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    && chmod +x /usr/local/bin/cloudflared

# 创建 choreo 用户
RUN adduser -D -u 10001 choreo && \
    mkdir -p /data /var/log/supervisor /var/run /dashboard

# 复制构建产物
COPY --from=builder /app/nezha-dashboard /dashboard/
COPY --from=builder /app/dashboard/dist /dashboard/dashboard-dist

# 复制配置
COPY --chown=choreo:choreo config.yaml.template /data/
COPY --chown=choreo:choreo start.sh /start.sh
COPY --chown=choreo:choreo supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN chmod +x /start.sh && \
    chown -R choreo:choreo /data /dashboard /var/log/supervisor /var/run

USER 10001
WORKDIR /dashboard

# 暴露默认端口 8008
EXPOSE 8008

CMD ["/start.sh"]
