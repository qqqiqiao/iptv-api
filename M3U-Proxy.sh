cat > m3u-proxy.sh <<'EOF'
#!/bin/bash
#################################################
#
# M3U Proxy v1.2.1 Cache 纯净修复版
# 修复Windows CRLF换行语法报错
#################################################
# ===============================
# 颜色常量
# ===============================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
# ===============================
# 基础配置
# ===============================
VERSION="1.2.1"
INSTALL_DIR="/opt/m3u-proxy-cache"
# ===============================
# 外部端口输入
# ===============================
read -p "请输入外部访问端口（默认10002）: " OUT_PORT
OUT_PORT=${OUT_PORT:-10002}
PORT=${OUT_PORT}
echo "外部访问端口: ${PORT}"
M3U_CONTAINER="m3u-proxy"
NGINX_CONTAINER="m3u-nginx-cache"
# ===============================
# LOGO打印
# ===============================
print_logo(){
echo -e "${CYAN}"
echo "
=================================
   M3U Proxy     修改版
             v${VERSION}
=================================
"
echo -e "${YELLOW}"
echo "Port : ${PORT}"
echo "Path : ${INSTALL_DIR}"
echo -e "${NC}"
}
# ===============================
# 主菜单
# ===============================
print_menu(){
clear
print_logo
echo -e "${PURPLE}"
echo "====== M3U Proxy 管理菜单 ======"
echo -e "${NC}"
echo -e "${BLUE}1)${NC} 部署 M3U Proxy Cache"
echo -e "${BLUE}2)${NC} 更新服务"
echo -e "${BLUE}3)${NC} 重启服务"
echo -e "${BLUE}4)${NC} 查看日志"
echo -e "${BLUE}5)${NC} 清理缓存"
echo -e "${BLUE}6)${NC} 查看状态"
echo -e "${BLUE}7)${NC} 删除服务"
echo -e "${RED}0)${NC} 退出"
echo
}
# ===============================
# 检测并安装Docker
# ===============================
check_docker(){
if ! command -v docker >/dev/null 2>&1
then
echo -e "${YELLOW}正在安装 Docker...${NC}"
curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker
else
echo -e "${GREEN}Docker 已安装${NC}"
fi
}
# ===============================
# 检测并安装Docker Compose
# ===============================
check_compose(){
if docker compose version >/dev/null 2>&1
then
echo -e "${GREEN}Docker Compose 已安装${NC}"
else
echo "安装 Docker Compose"
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
fi
}
# ===============================
# 初始化目录与空文件
# ===============================
init_dir(){
mkdir -p ${INSTALL_DIR}
mkdir -p ${INSTALL_DIR}/cache
mkdir -p ${INSTALL_DIR}/nginx-cache
touch ${INSTALL_DIR}/iptv.m3u
touch ${INSTALL_DIR}/whitelist.txt
touch ${INSTALL_DIR}/ip_whitelist.txt
touch ${INSTALL_DIR}/m3u_proxy.log
touch ${INSTALL_DIR}/security_config.json
}
# ===============================
# 获取服务器公网IP
# ===============================
get_ip(){
SERVER_IP=$(curl -s4 ifconfig.me 2>/dev/null)
if [ -z "$SERVER_IP" ];then
SERVER_IP="服务器IP"
fi
echo ${SERVER_IP}
}
# ===============================
# 生成随机12位密码
# ===============================
generate_password(){
tr -dc 'A-Za-z0-9@#%+=' </dev/urandom | head -c 12
}
# ===============================
# 设置后台管理员账号密码
# ===============================
set_admin(){
echo
echo -e "${CYAN}====== 管理员账号设置 ======${NC}"
read -p "请输入管理员用户名(默认 admin): " ADMIN_USERNAME
ADMIN_USERNAME=${ADMIN_USERNAME:-admin}
echo
echo "密码设置方式："
echo "1) 手动设置密码"
echo "2) 自动生成随机密码"
read -p "请选择(默认1): " PASS_MODE
if [ "${PASS_MODE}" = "2" ];then
ADMIN_PASSWORD=$(generate_password)
echo -e "${GREEN}已生成随机密码: ${ADMIN_PASSWORD}${NC}"
else
read -p "请输入管理员密码(默认8520): " ADMIN_PASSWORD
ADMIN_PASSWORD=${ADMIN_PASSWORD:-8520}
fi
}
# ===============================
# 保存环境配置
# ===============================
save_config(){
cat > ${INSTALL_DIR}/config.env <<ENV
ADMIN_USERNAME=${ADMIN_USERNAME}
ADMIN_PASSWORD=${ADMIN_PASSWORD}
PORT=${PORT}
ENV
}
# ===============================
# 生成Nginx缓存配置
# ===============================
create_nginx_conf(){
cat > ${INSTALL_DIR}/nginx.conf <<NGINX
worker_processes auto;
events {
    worker_connections 4096;
}
http {
    include mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;
    proxy_cache_path
    /var/cache/nginx
    levels=1:2
    keys_zone=hls_cache:200m
    max_size=15g
    inactive=30m
    use_temp_path=off;
    server {
        listen 80;
        server_name _;
        location ~ \.m3u8$ {
            proxy_pass http://m3u-proxy:5612;
            proxy_http_version 1.1;
            proxy_set_header Host \$host;
            proxy_cache hls_cache;
            proxy_cache_valid 200 5s;
            proxy_cache_use_stale error timeout updating;
        }
        location ~ \.ts$ {
            proxy_pass http://m3u-proxy:5612;
            proxy_http_version 1.1;
            proxy_set_header Host \$host;
            proxy_cache hls_cache;
            proxy_cache_valid 200 30m;
            proxy_cache_use_stale error timeout updating;
        }
        location / {
            proxy_pass http://m3u-proxy:5612;
            proxy_http_version 1.1;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_buffering on;
        }
    }
}
NGINX
}
# ===============================
# 生成docker-compose.yml
# ===============================
create_compose(){
SERVER_IP=$(get_ip)
cat > ${INSTALL_DIR}/docker-compose.yml <<COMPOSE
services:
  nginx-cache:
    image: nginx:latest
    container_name: ${NGINX_CONTAINER}
    restart: unless-stopped
    ports:
      - "${PORT}:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx-cache:/var/cache/nginx
    depends_on:
      - m3u-proxy
  m3u-proxy:
    image: hiyuelin/m3u-proxy:latest
    container_name: ${M3U_CONTAINER}
    restart: unless-stopped
    expose:
      - "5612"
    volumes:
      - ./iptv.m3u:/app/iptv.m3u
      - ./whitelist.txt:/app/whitelist.txt
      - ./ip_whitelist.txt:/app/ip_whitelist.txt
      - ./m3u_proxy.log:/app/m3u_proxy.log
      - ./security_config.json:/app/security_config.json
    environment:
      PROXY_SERVER: http://${SERVER_IP}:${PORT}
      DEBUG_MODE: False
      ENABLE_IP_WHITELIST: False
      CONSOLE_LOG_ENABLED: True
      LOG_LEVEL: INFO
      ORIGINAL_M3U_PATH: /app/iptv.m3u
      WHITE_LIST_PATH: /app/whitelist.txt
      IP_WHITELIST_PATH: /app/ip_whitelist.txt
      LOG_FILE_PATH: /app/m3u_proxy.log
      PORT: 5612
      HOST: 0.0.0.0
      ADMIN_USERNAME: ${ADMIN_USERNAME}
      ADMIN_PASSWORD: ${ADMIN_PASSWORD}
COMPOSE
}
# ===============================
# 部署完整服务
# ===============================
deploy_service(){
echo -e "${GREEN}开始部署 M3U Proxy v1.2.1 Cache Edition${NC}"
check_docker
check_compose
init_dir
set_admin
save_config
create_nginx_conf
create_compose
cd ${INSTALL_DIR}
echo -e "${YELLOW}停止旧容器...${NC}"
docker compose down 2>/dev/null
echo -e "${YELLOW}拉取镜像...${NC}"
docker compose pull
echo -e "${YELLOW}启动服务...${NC}"
docker compose up -d
sleep 3
SERVER_IP=$(get_ip)
echo
echo -e "${GREEN}===================================${NC}"
echo " M3U Proxy 部署完成"
echo -e "${GREEN}===================================${NC}"
echo "后台地址：http://${SERVER_IP}:${PORT}/admin"
echo "订阅地址：http://${SERVER_IP}:${PORT}/iptv.m3u"
echo "管理员账号：${ADMIN_USERNAME}"
echo "管理员密码：${ADMIN_PASSWORD}"
echo "配置目录：${INSTALL_DIR}"
read -p "按回车返回菜单..."
}
# ===============================
# 更新镜像重启服务
# ===============================
update_service(){
echo -e "${YELLOW}开始更新服务...${NC}"
cd ${INSTALL_DIR}
docker compose pull
docker compose up -d
echo -e "${GREEN}更新完成${NC}"
read -p "按回车返回菜单..."
}
# ===============================
# 重启容器
# ===============================
restart_service(){
echo -e "${YELLOW}正在重启服务...${NC}"
cd ${INSTALL_DIR}
docker compose restart
echo -e "${GREEN}重启完成${NC}"
read -p "按回车返回菜单..."
}
# ===============================
# 查看运行状态
# ===============================
show_status(){
echo "=============================="
echo " M3U Proxy 运行状态"
echo "=============================="
cd ${INSTALL_DIR}
docker compose ps
echo "访问端口：${PORT}"
echo "缓存占用：$(du -sh ${INSTALL_DIR}/nginx-cache 2>/dev/null)"
echo "配置文件：${INSTALL_DIR}/config.env"
read -p "按回车返回菜单..."
}
# ===============================
# 实时查看日志
# ===============================
show_logs(){
echo "请选择日志："
echo "1) Nginx Cache 日志"
echo "2) M3U Proxy 程序日志"
echo "0) 返回菜单"
read -p "请输入编号: " log_opt
case ${log_opt} in
1) docker logs -f ${NGINX_CONTAINER} ;;
2) docker logs -f ${M3U_CONTAINER} ;;
0) return ;;
*) echo -e "${RED}无效选择${NC}" ;;
esac
}
# ===============================
# 清空Nginx缓存
# ===============================
clear_cache(){
echo -e "${YELLOW}清理缓存中...${NC}"
rm -rf ${INSTALL_DIR}/nginx-cache/*
docker exec ${NGINX_CONTAINER} nginx -s reload 2>/dev/null
echo -e "${GREEN}缓存清理完毕${NC}"
read -p "按回车返回菜单..."
}
# ===============================
# 彻底卸载服务
# ===============================
remove_service(){
echo -e "${RED}即将卸载 M3U Proxy Cache${NC}"
read -p "确认删除容器服务？(y/N): " confirm
if [[ "${confirm}" =~ ^[Yy]$ ]];then
cd ${INSTALL_DIR}
docker compose down
docker rm -f ${NGINX_CONTAINER} ${M3U_CONTAINER} 2>/dev/null
read -p "是否删除本地配置与缓存文件？(y/N): " del_data
if [[ "${del_data}" =~ ^[Yy]$ ]];then
rm -rf ${INSTALL_DIR}
fi
echo -e "${GREEN}卸载完成${NC}"
else
echo "已取消卸载"
fi
read -p "按回车返回菜单..."
}
# ===============================
# 主循环菜单
# ===============================
while true;do
print_menu
read -p "请输入功能编号: " opt
case ${opt} in
1) deploy_service ;;
2) update_service ;;
3) restart_service ;;
4) show_logs ;;
5) clear_cache ;;
6) show_status ;;
7) remove_service ;;
0) echo -e "${GREEN}脚本退出，再见${NC}"; exit 0 ;;
*) echo -e "${RED}输入无效，请重新选择${NC}"; sleep 2 ;;
esac
done
EOF