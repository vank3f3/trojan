FROM alpine:3.7
LABEL maintainer="imlonghao"
ENV HTTPDIR     /usr/share/nginx/html/
ENV EXECFILE	/usr/sbin/httpv
ENV PASSWD  test123
ENV KEYPASSWD lihxlinux
ARG version=1.8.1

WORKDIR /app
RUN apk add --no-cache --virtual build-dependencies cmake g++ make boost-dev && \
    apk add --no-cache mariadb-dev && \
    apk add --no-cache nginx && \
    wget https://github.com/trojan-gfw/trojan/archive/v${version}.tar.gz && \
    tar zxf v${version}.tar.gz && \
    cd trojan-${version} && \
    sed -i '1iSET(Boost_USE_STATIC_LIBS ON)' CMakeLists.txt && \
    sed -i '1iSET(CMAKE_EXE_LINKER_FLAGS "-static-libgcc -static-libstdc++")' CMakeLists.txt && \
    cmake . && \
    make && \
    mv trojan /app && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk /usr/share/man /app/trojan-${version} /app/v${version}.tar.gz
    
# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log
    
#ADD client
ADD win.zip ${HTTPDIR}
ADD macos.zip ${HTTPDIR}
ADD android.apk ${HTTPDIR}
ADD SwitchyOmega-Chromium-2.5.15.crx ${HTTPDIR}
ADD vc_redist.x64.exe ${HTTPDIR}
ADD vc_redist.x86.exe ${HTTPDIR}
ADD index.html ${HTTPDIR}
COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf


#ADD server.conf /app/conf/config.json
ADD private.crt /app/conf/private.crt
ADD private.key /app/conf/private.key
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 443
ENTRYPOINT ["/entrypoint.sh"]