build_path=`pwd`



cd $build_path

if [ $1 == "cache" ]
then
    # build cache
    if [ $2 == "compile" ]
    then

        cd $build_path
        cd ngx_openresty/bundle/nginx-1.9.3/
        patch -p1 < $build_path/ngx_openresty/bundle/ngx_req_status-master/write_filter-1.7.11.patch

        cd $build_path
        mkdir -p /home/cdn/cache/
        cd ngx_openresty/
        dos2unix ./configure
        chmod +x ./configure

        dos2unix ./bundle/nginx-1.9.3/configure
        chmod +x ./bundle/nginx-1.9.3/configure

        ./configure --prefix=/home/cdn/cache --with-luajit --add-module=./bundle/ngx_req_status-master
        chmod +x ./bundle/install
        chmod +x ./build/install
        dos2unix ./bundle/nginx-1.9.3/configure
        chmod +x ./bundle/nginx-1.9.3/configure

        make
        make install
    elif [ $2 == "nocompile" ]
    then
        echo "will not compile ngx_openresty."
    else
    	echo "please input ./build.sh [cashe|slb] [compile|nocompile]"
        exit
    fi
    

    cd $build_path
    rm -rf /home/cdn/cache/nginx/*_temp/
    rm -rf /home/cdn/cache/nginx/html/
    rm -rf /home/cdn/cache/nginx/conf/*
    rm -rf /home/cdn/cache/nginx/lua/*

    cp  ./ngx_openresty/bundle/lua-http-client/* /home/cdn/cache/lualib/resty/
    
    cp  ./cache/conf/* /home/cdn/cache/nginx/conf/
    mkdir -p /home/cdn/cache/nginx/lua/
    cp  ./cache/lua/* /home/cdn/cache/nginx/lua/
    cp  ./anti_leech/anti_leech.lua /home/cdn/cache/nginx/lua/
    cp  ./anti_leech/authinfo.so /home/cdn/cache/nginx/lua/
        
    tar zcvf cache.tar.gz /home/cdn/cache/

elif [ $1 == "slb" ]
then
    # build slb
    if [ $2 == "compile" ]
    then

        cd $build_path
        cd ngx_openresty/bundle/nginx-1.9.3/
        patch -p1 < $build_path/ngx_openresty/bundle/ngx_req_status-master/write_filter-1.7.11.patch


        cd $build_path
        mkdir -p /home/cdn/slb/
        cd ngx_openresty/
        dos2unix ./configure
        chmod +x ./configure
        dos2unix ./bundle/nginx-1.9.3/configure
        chmod +x ./bundle/nginx-1.9.3/configure

        ./configure --prefix=/home/cdn/slb --with-luajit --add-module=./bundle/ngx_req_status-master
        chmod +x ./bundle/install
        chmod +x ./build/install
        dos2unix ./bundle/nginx-1.9.3/configure
        chmod +x ./bundle/nginx-1.9.3/configure

        make
        make install
    elif [ $2 == "nocompile" ]
    then
        echo "will not compile ngx_openresty."
    else
    	echo "please input ./build.sh [cashe|slb] [compile|nocompile]"
        exit
    fi
    
    cd $build_path
    rm -rf /home/cdn/slb/nginx/*_temp/
    rm -rf /home/cdn/slb/nginx/html/
    rm -rf /home/cdn/slb/nginx/conf/*
    rm -rf /home/cdn/slb/nginx/lua/*

    cp  ./ngx_openresty/bundle/lua-http-client/* /home/cdn/slb/lualib/resty/
    

    cp  ./slb/conf/* /home/cdn/slb/nginx/conf/
    mkdir -p /home/cdn/slb/nginx/lua/
    cp  ./slb/lua/* /home/cdn/slb/nginx/lua/
    cp  ./anti_leech/anti_leech.lua /home/cdn/slb/nginx/lua/
    cp  ./anti_leech/authinfo.so /home/cdn/slb/nginx/lua/
        
    tar zcvf slb.tar.gz /home/cdn/slb/

else

    echo "please input ./build.sh [cashe|slb] [compile|nocompile]"
    exit
    
fi    
