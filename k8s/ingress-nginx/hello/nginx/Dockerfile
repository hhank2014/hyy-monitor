from centos

MAINTAINER TG Ops Group
RUN useradd www -s /sbin/nolog
RUN yum install -y openssl-devel pcre-devel yum-utils
RUN yum install -y https://nginx.org/packages/rhel/7/x86_64/RPMS/nginx-1.16.0-1.el7.ngx.x86_64.rpm
RUN yum clean all
RUN yum install -y nginx
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./default.conf /etc/nginx/conf.d/default.conf

RUN echo "TG Ops Group CentOS 7 nginx" > /usr/share/nginx/html/index.html

CMD ["nginx", "-g", "daemon off;"]
