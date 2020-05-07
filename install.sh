# disable SELINUX
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
#
# disable firewall
systemctl stop firewalld
systemctl disable firewalld
systemctl mask firewalld
#
# nginx repo creation
cat > /etc/yum.repos.d/nginx.repo <<EOF
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=0
enabled=1
EOF
#
# yum installs
yum -y install epel-release
yum -y install vim tcpdump wget git jq
yum -y install nginx
yum -y groupinstall "Development Tools"
yum -y install pcre-devel openssl-devel libxml2-devel libxslt-devel gd-devel perl-ExtUtils-Embed GeoIP-devel
yum -y remove nginx
#
# get nginx installer
#wget http://nginx.org/download/nginx-1.14.0.tar.gz
tar xvzf nginx-1.14.0.tar.gz
cd nginx-1.14.0
#git clone https://github.com/nginx/njs.git
#git clone https://github.com/arut/nginx-rtmp-module.git
mv ../njs .
mv ../nginx-rtmp-module .
#
# install nginx
./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic -fPIC' --with-ld-opt='-Wl,-z,relro -Wl,-z,now -pie' --add-module=nginx-rtmp-module
make
make install
#
# create nginx systemd unit file
cat > /usr/lib/systemd/system/nginx.service <<EOF
[Unit]
Description=nginx - high performance web server
Documentation=https://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPost=/bin/sleep 0.1
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx.conf
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s TERM \$MAINPID
ExecStopPost=/bin/rm -f /run/nginx.pid

[Install]
WantedBy=multi-user.target
EOF
#
# enable nginx at startup
systemctl enable nginx.service
mkdir /var/cache/nginx
systemctl start nginx
systemctl status nginx
#
# FFMPEG DL and Install
# download rpm's
rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
#
# install ffmpeg
yum -y install ffmpeg
ffmpeg
#
# install supervisord
yum -y install supervisor
# edit supervisor conf
cat >> /etc/supervisord.conf <<EOF
[program:rtmp_transmux]
command=/usr/bin/ffmpeg -i "rtp://127.0.0.1:20000" -acodec aac -strict experimental -ar 44100 -b:a 192k -vcodec copy -f flv "rtmp://127.0.0.1:1935/live/mcrview" 
EOF
#
# enable and start supervisord service
systemctl enable supervisord
systemctl start supervisord
#
cd ../
# extract webpage
sudo tar -xvf webpage.tar -C /
# set correct public address in webpage
webpage="/etc/nginx/html/mcr/softpanel.html"
old=$(cat $webpage | grep -o rtmp.*:1935)
echo $old
new=rtmp:\\/\\/$(curl -s ifconfig.me):1935
echo hello
#array of rtmp entries
rtmparray=( $old )
echo hello 2
for rtmp in ${rtmparray[@]}; do
echo $rtmp
oldslash=$(echo ${rtmp////\\/})
echo $oldslash $new
sed -i 's/'$oldslash'/'$new'/g' $webpage
done
#
# add rtmp server to nginx
cat >> /etc/nginx/nginx.conf <<EOF
rtmp {
server {
listen 1935;
        chunk_size 4000;
        # one publisher, many subscribers
        application live {
            # enable live streaming
            live on;
            # publish only from localhost
            allow publish all;
       }
 }
}
EOF
# add dav method to nginx
sed -i 's/http\ {/http\ {\n\ \ \ \ dav_methods PUT;/' /etc/nginx/nginx.conf
sed -i '0,/location\ \/\ {/s/location\ \/\ {/location\ \/\ {\n\ \ \ \ \ \ \ \ \ if\ ($request_method\ =\ OPTIONS\ )\ {add_header\ '\''Access-Control-Allow-Origin'\''\ '*'\'';\ add_header\ '\''Access-Control-Allow-Methods'\''\ '\''GET,\ PUT,\ OPTIONS'\'';\ return\ 200;}/' /etc/nginx/nginx.conf
sed -i 's/#user\ \ nobody/user\ \ root/' /etc/nginx/nginx.conf
nginx -t
nginx -s reload
systemctl restart supervisord
cp scripts/webpageurlset.sh /tmp/
echo "* * * * * root /tmp/webpageurlset.sh" >> /etc/crontab
cd ~
echo DONE!
currentpip=$(curl ifconfig.me)
echo Website is running and available here: http://$currentpip/mcr/softpanel.html
