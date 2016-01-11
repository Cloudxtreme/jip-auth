
docker pull index.alauda.cn/zhengxiaochuan/jip-auth_https_server
docker tag index.alauda.cn/zhengxiaochuan/jip-auth_https_server jip-auth
docker run -d --name jip-auth -p 443:443 -p 6666:6666 -v /home/CaaS/jip-auth/auth/conf/:/usr/local/openresty/nginx/conf/ -v /home/CaaS/jip-auth/auth/lua/:/usr/local/openresty/nginx/lua --link jip-registry:jip-registry   jip-auth


