webpage="/etc/nginx/html/mcr/softpanel.html"
javascript="/etc/nginx/html/mcr/js/pagescript.js"
hlsURL="https://cdn.com/out/v1/hls/index.m3u8"
api="https://api.execute-api.us-west-2.amazonaws.com/eng"

# RTMP URL change
old=$(cat $webpage | grep -o rtmp.*:1935)
new=rtmp:\\/\\/$(curl -s ifconfig.me):1935

#array of rtmp entries
rtmparray=( $old )
for rtmp in ${rtmparray[@]}; do
  oldslash=$(echo ${rtmp////\\/})
  sed -i 's/'$oldslash'/'$new'/g' $webpage
done

old=$(cat $javascript | grep -o rtmp.*:1935)
new=rtmp:\\/\\/$(curl -s ifconfig.me):1935

#array of rtmp entries
rtmparray=( $old )
for rtmp in ${rtmparray[@]}; do
  oldslash=$(echo ${rtmp////\\/})
  sed -i 's/'$oldslash'/'$new'/g' $javascript
done

# HLS index change
old=$(cat $webpage | grep -o http.*m3u8)
new=$(echo ${hlsURL////\\/})

#array of hls entries
hlsarray=( $old )
for hls in ${hlsarray[@]}; do
  oldslash=$(echo ${hls////\\/})
  sed -i 's/'$oldslash'/'$new'/g' $webpage
done

old=$(cat $javascript | grep -o http.*m3u8)

#array of hls entries
hlsarray=( $old )
for hls in ${hlsarray[@]}; do
  oldslash=$(echo ${hls////\\/})
  sed -i 's/'$oldslash'/'$new'/g' $javascript
done

# API Endpoint Update
old=$(cat $javascript | grep -o http.*eng)
new=$(echo ${api////\\/})
apiarray=( $old )
for apis in ${apiarray[@]}; do
  oldslash=$(echo ${apis////\\/})
  sed -i 's/'$oldslash'/'$new'/g' $javascript
done
