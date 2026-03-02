#!/bin/sh
set -e

echo "=== Nezha Dashboard on Choreo ==="

# 检查环境变量
for var in TUNNEL_TOKEN SITE_URL DATABASE_URL MS_CLIENT_ID MS_CLIENT_SECRET OAUTH_ADMIN; do
    eval "val=\$$var"
    if [ -z "$val" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

# 转换数据库 URL（postgresql:// -> postgres://）
DB_URL="$DATABASE_URL"
case "$DB_URL" in
    postgresql://*) DB_URL="postgres${DB_URL#postgresql}" ;;
esac

# 添加 sslmode
if ! echo "$DB_URL" | grep -q "sslmode="; then
    if echo "$DB_URL" | grep -q "?"; then
        DB_URL="${DB_URL}&sslmode=require"
    else
        DB_URL="${DB_URL}?sslmode=require"
    fi
fi

export DATABASE_URL="$DB_URL"

echo "Waiting for database..."
until pg_isready -d "$DATABASE_URL" 2>/dev/null; do
    sleep 2
done
echo "Database connected"

# 生成配置文件
envsubst < /data/config.yaml.template > /tmp/config.yaml

echo "Starting Nezha Dashboard on port 8008..."

# 启动哪吒面板（后台）
/dashboard/nezha-dashboard --config /tmp/config.yaml &

# 等待面板启动
sleep 5

echo "Starting Cloudflare Tunnel..."

# 启动 cloudflared（前台保持容器运行）
exec /usr/local/bin/cloudflared tunnel run --no-autoupdate --token "$TUNNEL_TOKEN"
