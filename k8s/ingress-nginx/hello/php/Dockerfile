from centos

MAINTAINER TG Ops Group
RUN useradd www -s /sbin/nolog
RUN yum install -y epel-release gcc gcc-c++ make \
    yum install -y https://mirror.webtatic.com/yum/el7/webtatic-release.rpm \
    yum clean all

RUN yum install -y php72w-cli php72w-common php72w-mysqlnd php72w-devel \
                   php72w-fpm php72w-gd php72w-mbstring php72w-mcrypt \
                   php72w-bcmath php72w-ldap php72w-opcache php72w-pdo \
	           php72w-pear php72w-pecl-igbinary php72w-process \
		   php72w-xml php72w-pecl-redis php72w-mbstring php72w-mcrypt\
		   php72w-pear \

RUN yum clean all
RUN yum install -y php72w-pear
#RUN echo '' | pecl install swoole

EXPOSE 9000

CMD ["php-fpm", "-F"]
