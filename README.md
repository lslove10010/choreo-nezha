# Nezha Dashboard on Choreo + Cloudflare Tunnel

## 环境变量配置

| 变量名 | 说明 | 获取位置 |
|--------|------|---------|
| TUNNEL_TOKEN | Cloudflare Tunnel Token | Cloudflare Zero Trust → Networks → Tunnels |
| SITE_URL | 你的域名 | Cloudflare 托管的域名，如 https://nezha.example.com |
| DATABASE_URL | PostgreSQL 连接串 | Choreo Console → Database → Connect |
| MS_CLIENT_ID | Azure AD 应用 ID | Azure Portal → App registrations → Application (client) ID |
| MS_CLIENT_SECRET | Azure AD 客户端密码 | Azure Portal → Certificates & secrets → New client secret |
| OAUTH_ADMIN | 管理员邮箱 | 你的微软账号邮箱，如 admin@outlook.com |

## 部署步骤

1. Fork 本仓库
2. 在 Choreo 创建 PostgreSQL 数据库
3. 在 Choreo 创建 Service 组件，连接本仓库
4. 配置所有环境变量
5. 部署

## Agent 连接

```bash
curl -L https://raw.githubusercontent.com/nezhahq/scripts/main/agent/install.sh -o nezha-agent.sh && chmod +x nezha-agent.sh

# 安装时填写：
# Dashboard: nezha-api.yourdomain.com:443
# Secret: 从面板获取
# TLS: yes
# WebSocket: yes
