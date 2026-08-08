#!/bin/bash


#################################################
#
# M3U Proxy v1.2.1
#
# 公众号【潇雨萌萌�?
#################################################


# ===============================
# 颜色
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

AUTHOR="M3U Proxy Cache Edition"


INSTALL_DIR="/opt/m3u-proxy-cache"


# ===============================
# 设置外部访问端口
# ===============================

read -p "请输入外部访问端口（默认10002�? " OUT_PORT

OUT_PORT=${OUT_PORT:-10002}

echo "外部访问端口: ${OUT_PORT}"


M3U_CONTAINER="m3u-proxy"


NGINX_CONTAINER="m3u-nginx-cache"







# ===============================
# LOGO
# ===============================


print_logo(){


echo -e "${CYAN}"

echo "

=================================

   M3U Proxy     修改�?

             v${VERSION}


=================================

"


echo -e "${YELLOW}"

echo "Port : ${PORT}"

echo "Path : ${INSTALL_DIR}"

echo -e "${NC}"


}









# ===============================
# 菜单
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


echo -e "${BLUE}6)${NC} 查看状�?


echo -e "${BLUE}7)${NC} 删除服务"


echo -e "${RED}0)${NC} 退�?


echo


}









# ===============================
# Docker检�?
# ===============================


check_docker(){



if ! command -v docker >/dev/null 2>&1

then


echo -e "${YELLOW}"

echo "正在安装 Docker..."

echo -e "${NC}"


curl -fsSL https://get.docker.com | sh


systemctl enable docker


systemctl start docker



else


echo -e "${GREEN}"

echo "Docker 已安�?

echo -e "${NC}"



fi



}









# ===============================
# Compose检�?
# ===============================


check_compose(){


if docker compose version >/dev/null 2>&1

then


echo -e "${GREEN}"

echo "Docker Compose 已安�?

echo -e "${NC}"



else


echo "安装 Docker Compose"



curl -L \
https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
-o /usr/local/bin/docker-compose



chmod +x /usr/local/bin/docker-compose



fi



}









# ===============================
# 初始化目�?
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
# 获取IP
# ===============================


get_ip(){


SERVER_IP=$(curl -s4 ifconfig.me)



if [ -z "$SERVER_IP" ]

then


SERVER_IP="服务器IP"



fi



echo ${SERVER_IP}



}
# ===============================
# 随机密码生成
# ===============================


generate_password(){


PASSWORD=$(tr -dc 'A-Za-z0-9@#%+=' </dev/urandom | head -c 12)


echo ${PASSWORD}


}









# ===============================
# 设置管理员账号密�?
# ===============================


set_admin(){


echo


echo -e "${CYAN}"

echo "====== 管理员账号设�?======"

echo -e "${NC}"



read -p "请输入管理员用户�?默认 admin): " ADMIN_USERNAME



if [ -z "${ADMIN_USERNAME}" ]

then


ADMIN_USERNAME="admin"



fi






echo


echo "密码设置方式�?


echo "1) 手动设置密码"


echo "2) 自动生成随机密码"



read -p "请选择(默认1): " PASS_MODE




if [ "${PASS_MODE}" = "2" ]

then



ADMIN_PASSWORD=$(generate_password)



echo


echo -e "${GREEN}"

echo "已生成随机密�?"

echo "${ADMIN_PASSWORD}"

echo -e "${NC}"



else



read -p "请输入管理员密码(默认8520): " ADMIN_PASSWORD



if [ -z "${ADMIN_PASSWORD}" ]

then


ADMIN_PASSWORD="8520"



fi



fi






}



 
 





# ===============================
# 保存配置
# ===============================


save_config(){



cat > ${INSTALL_DIR}/config.env <<EOF


ADMIN_USERNAME=${ADMIN_USERNAME}


ADMIN_PASSWORD=${ADMIN_PASSWORD}


PORT=${PORT}


EOF



}









# ===============================
# 创建 Nginx 配置
# ===============================


create_nginx_conf(){



cat > ${INSTALL_DIR}/nginx.conf <<'EOF'


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







        # m3u8缓存


        location ~ \.m3u8$ {



            proxy_pass http://m3u-proxy:5612;



            proxy_http_version 1.1;



            proxy_set_header Host $host;



            proxy_cache hls_cache;



            proxy_cache_valid 200 5s;



            proxy_cache_use_stale error timeout updating;



        }








        # TS缓存


        location ~ \.ts$ {



            proxy_pass http://m3u-proxy:5612;



            proxy_http_version 1.1;



            proxy_set_header Host $host;



            proxy_cache hls_cache;



            proxy_cache_valid 200 30m;



            proxy_cache_use_stale error timeout updating;



        }








        # 后台/M3U访问


        location / {



            proxy_pass http://m3u-proxy:5612;



            proxy_http_version 1.1;



            proxy_set_header Host $host;



            proxy_set_header X-Real-IP $remote_addr;



            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;



            proxy_buffering on;



        }



    }



}



EOF



}

# ===============================
# 创建 docker-compose.yml
# ===============================


create_compose(){


cat > ${INSTALL_DIR}/docker-compose.yml <<EOF


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



      PROXY_SERVER: http://$(get_ip):${PORT}



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




EOF



}









# ===============================
# 部署服务
# ===============================


deploy_service(){



echo -e "${GREEN}"

echo "开始部�?M3U Proxy v1.2.1 Cache Edition"

echo -e "${NC}"





check_docker



check_compose



init_dir





set_admin



save_config



create_nginx_conf



create_compose






cd ${INSTALL_DIR}






echo -e "${YELLOW}"

echo "停止旧容�?.."

echo -e "${NC}"



docker compose down 2>/dev/null






echo -e "${YELLOW}"

echo "拉取镜像..."

echo -e "${NC}"



docker compose pull






echo -e "${YELLOW}"

echo "启动服务..."

echo -e "${NC}"



docker compose up -d





sleep 3






SERVER_IP=$(get_ip)





echo


echo -e "${GREEN}"

echo "==================================="

echo " M3U Proxy 部署完成"

echo "==================================="

echo -e "${NC}"




echo


echo "后台地址�?

echo "http://${SERVER_IP}:${PORT}/admin"



echo


echo "订阅地址�?

echo "http://${SERVER_IP}:${PORT}/iptv.m3u"



echo


echo "管理员："

echo "${ADMIN_USERNAME}"



echo


echo "密码�?

echo "${ADMIN_PASSWORD}"



echo


echo "配置文件�?

echo "${INSTALL_DIR}/config.env"



echo



read -p "按回车返回菜�?.."



}
# ===============================
# 更新服务
# ===============================


update_service(){


echo -e "${YELLOW}"

echo "开始更新服�?.."

echo -e "${NC}"



cd ${INSTALL_DIR}



docker compose pull



docker compose up -d



echo -e "${GREEN}"

echo "更新完成"

echo -e "${NC}"



read -p "按回车返回菜�?.."



}









# ===============================
# 重启服务
# ===============================


restart_service(){



echo -e "${YELLOW}"

echo "正在重启服务..."

echo -e "${NC}"



cd ${INSTALL_DIR}



docker compose restart



echo -e "${GREEN}"

echo "重启完成"

echo -e "${NC}"



read -p "按回车返回菜�?.."



}









# ===============================
# 查看状�?
# ===============================


show_status(){



echo

echo "=============================="

echo " M3U Proxy 运行状�?

echo "=============================="



echo



cd ${INSTALL_DIR}



docker compose ps



echo



echo "端口�?

echo "${PORT}"



echo



echo "缓存目录�?

du -sh ${INSTALL_DIR}/nginx-cache 2>/dev/null



echo



echo "配置文件�?

echo "${INSTALL_DIR}/config.env"



echo



read -p "按回车返回菜�?.."



}









# ===============================
# 查看日志
# ===============================


show_logs(){



echo


echo "请选择日志�?


echo


echo "1) Nginx Cache"


echo "2) M3U Proxy"


echo "0) 返回"



read -p "请选择: " log



case ${log} in



1)


docker logs -f ${NGINX_CONTAINER}


;;



2)


docker logs -f ${M3U_CONTAINER}


;;



0)


return


;;



*)


echo "错误选择"


;;



esac



}









# ===============================
# 清理缓存
# ===============================


clear_cache(){



echo -e "${YELLOW}"

echo "正在清理缓存..."

echo -e "${NC}"



cd ${INSTALL_DIR}




rm -rf ${INSTALL_DIR}/nginx-cache/*





docker exec ${NGINX_CONTAINER} nginx -s reload 2>/dev/null





echo -e "${GREEN}"

echo "缓存清理完成"

echo -e "${NC}"



read -p "按回车返回菜�?.."



}









# ===============================
# 删除服务
# ===============================


remove_service(){



echo -e "${RED}"

echo "准备删除 M3U Proxy Cache Edition"

echo -e "${NC}"



read -p "确认删除服务�?y/N): " confirm





if [[ "${confirm}" == "y" || "${confirm}" == "Y" ]]

then



cd ${INSTALL_DIR}



docker compose down



docker rm -f ${NGINX_CONTAINER} 2>/dev/null


docker rm -f ${M3U_CONTAINER} 2>/dev/null





echo



read -p "是否删除配置文件和数据？(y/N): " del





if [[ "${del}" == "y" || "${del}" == "Y" ]]

then



cd /



rm -rf ${INSTALL_DIR}



fi





echo -e "${GREEN}"

echo "删除完成"

echo -e "${NC}"



else



echo "已取�?



fi





read -p "按回车返回菜�?.."



}









# ===============================
# 主程�?
# ===============================


while true

do



print_menu



read -p "请输入选项数字: " choice



case ${choice} in



1)


deploy_service


;;



2)


update_service


;;



3)


restart_service


;;



4)


show_logs


;;



5)


clear_cache


;;



6)


show_status


;;



7)


remove_service


;;



0)



echo -e "${GREEN}"

echo "感谢使用 M3U Proxy v1.2.1"

echo -e "${NC}"



exit 0



;;



*)



echo -e "${RED}"

echo "无效选项"

echo -e "${NC}"



sleep 2



;;



esac



done


