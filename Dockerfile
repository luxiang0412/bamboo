FROM golang:1.8

ENV DEBIAN_FRONTEND noninteractive

RUN cat /etc/apt/sources.list.d/backports.list && \
    cat /etc/apt/sources.list.d/haproxy.list && \
    echo deb http://httpredir.debian.org/debian jessie main | tee /etc/apt/sources.list.d/backports.list && \
    echo 'deb http://httpredir.debian.org/debian jessie-updates main' >> /etc/apt/sources.list.d/backports.list && \
    curl https://haproxy.debian.net/bernat.debian.org.gpg | \
      apt-key add - && \
    echo deb http://haproxy.debian.net jessie-backports-1.8 main | \
      tee /etc/apt/sources.list.d/haproxy.list && \
    #sed -i /jessie-updates/d /etc/apt/sources.list && \
    #sed -i /jessie\\/updates/d /etc/apt/sources.list && \
    #sed -i /jessie/d /etc/apt/sources.list && \
    #dpkg -i /tmp/dpkg/*.deb && \
    #echo 'deb http://mirrors.aliyun.com/debian/ jessie main non-free contrib' > /etc/apt/sources.list && \
    #echo 'deb http://mirrors.aliyun.com/debian/ jessie-proposed-updates main non-free contrib' >> /etc/apt/sources.list && \
    #echo 'deb-src http://mirrors.aliyun.com/debian/ jessie main non-free contrib' >> /etc/apt/sources.list && \
    #echo 'deb-src http://mirrors.aliyun.com/debian/ jessie-proposed-updates main non-free contrib' >> /etc/apt/sources.list && \
    #echo 'deb https://mirrors.tuna.tsinghua.edu.cn/debian/ jessie main contrib non-free' > /etc/apt/sources.list && \
    #echo 'deb https://mirrors.tuna.tsinghua.edu.cn/debian/ jessie-updates main contrib non-free' >> /etc/apt/sources.list && \
    #echo 'deb https://mirrors.tuna.tsinghua.edu.cn/debian/ jessie-backports main contrib non-free' >> /etc/apt/sources.list && \
    #echo 'deb https://mirrors.tuna.tsinghua.edu.cn/debian-security jessie/updates main contrib non-free' >> /etc/apt/sources.list && \
    #cat /etc/apt/sources.list && \
    #apt-get clean all && \
    apt-get update -yqq && \
    apt-get install -yqq software-properties-common && \
    apt-get install -yqq git mercurial supervisor && \
    apt-get install -yqq haproxy=1.8.\* && \
    rm -rf /var/lib/apt/lists/*

ADD builder/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD builder/run.sh /run.sh

WORKDIR /go/src/github.com/QubitProducts/bamboo

RUN go get github.com/tools/godep && \
    go get -t github.com/smartystreets/goconvey

ADD . /go/src/github.com/QubitProducts/bamboo

RUN go build && \
    ln -s /go/src/github.com/QubitProducts/bamboo /var/bamboo && \
    mkdir -p /run/haproxy && \
    mkdir -p /var/log/supervisor

VOLUME /var/log/supervisor

RUN apt-get clean && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup && \
    rm -f /etc/ssh/ssh_host_*

EXPOSE 80 8000

CMD /run.sh

