webpage="/etc/nginx/html/mcr/softpanel.html"

old=$(cat $webpage | grep -o rtmp.*:1935)
new=rtmp:\\/\\/$(curl -s ifconfig.me):1935

#array of rtmp entries
rtmparray=( $old )
for rtmp in ${rtmparray[@]}; do
  oldslash=$(echo ${rtmp////\\/})
  sed -i 's/'$oldslash'/'$new'/g' $webpage
done

javascript="/etc/nginx/html/js/pagescript.js"

old=$(cat $javascript | grep -o rtmp.*:1935)
new=rtmp:\\/\\/$(curl -s ifconfig.me):1935

#array of rtmp entries
rtmparray=( $old )
for rtmp in ${rtmparray[@]}; do
  oldslash=$(echo ${rtmp////\\/})
  sed -i 's/'$oldslash'/'$new'/g' $javascript
done
