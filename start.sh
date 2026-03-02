#!/bin/sh
set -e

echo "=== Nezha Dashboard on Choreo ==="
echo "Port: 8008 (default)"

# 检查环境变量
check_env() {
    if [ -z "$1" ]; then
        echo "Error: $2 is not set"
        exit 1
    fi
}

check_env "$TUNNEL_TOKEN" "TUNNEL_TOKEN"
check_env "$SITE_URL" "SITE_URL"
check_env "$DATABASE_URL" "DATABASE_URL"
check_env "$MS_CLIENT_ID" "MS_CLIENT_ID"
check_env "$MS_CLIENT_SECRET" "MS_CLIENT_SECRET"
check_env "$OAUTH_ADMIN" "OAUTH_ADMIN"

# 转换数据库 URL 格式
case "$DATABASE_URL" in
    postgresql://*)
        DATABASE_URL="postgres${DATABASE_URL#postgresql}"
        ;;
esac

# 添加 sslmode
if ! echo "$DATABASE_URL" | grep -q "sslmode="; then
    if echo "$DATABASE_URL" | grep -q "?"; then
        DATABASE_URL="${DATABASE_URL}&sslmode=require"
    else
        DATABASE_URL="${DATABASE_URL}?sslmode=require"
    fi
fi

export DATABASE_URL

echo "Waiting for database..."
until pg_isready -d "$DATABASE_URL" 2>/dev/null; do
    sleep 2
done
echo "Database connected"

# 生成配置文件
envsubst < /data/config.yaml.template > /data/config.yaml

echo "Starting Nezha Dashboard on port 8008..."

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
