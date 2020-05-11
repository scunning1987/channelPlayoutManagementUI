#!/bin/bash

#vars
webpage="/etc/nginx/html/mcr/softpanel.html"
javascript="/etc/nginx/html/mcr/js/pagescript.js"
urlUpdates="/etc/nginx/html/urlUpdates"
dashboardsetup="/etc/nginx/html/dashboard-client.html"

### function start

hls_url_update() {
  echo "hls function"
  # variables passed
  # $1 = webpage
  # $2 = javascript
  # $3 = urlUpdates

  hlsURL=$(cat $3 | jq -r '.Updates.hlsURL')

  # HLS index change
  old=$(cat $1 | grep -o http.*m3u8)
  new=$(echo ${hlsURL////\\/})

  #array of hls entries
  hlsarray=( $old )
  for hls in ${hlsarray[@]}; do
    oldslash=$(echo ${hls////\\/})
    sed -i 's/'$oldslash'/'$new'/g' $1
  done

  old=$(cat $2 | grep -o http.*m3u8)

  #array of hls entries
  hlsarray=( $old )
  for hls in ${hlsarray[@]}; do
    oldslash=$(echo ${hls////\\/})
    sed -i 's/'$oldslash'/'$new'/g' $2
  done  
}

api_url_update() {
  # variables passed
  # $1 = webpage
  # $2 = javascript
  # $3 = urlUpdates
  # $4 = dashboardsetup

  apiURL=$(cat $3 | jq -r '.Updates.apiURL')

  # API Endpoint Update
  old=$(cat $2 | grep -o http.*/eng)
  new=$(echo ${apiURL////\\/})
  apiarray=( $old )
    for apis in ${apiarray[@]}; do
    oldslash=$(echo ${apis////\\/})
    sed -i 's/'$oldslash'/'$new'/g' $2
  done
  old=$(cat $4 | grep -o http.*/eng)
  new=$(echo ${apiURL////\\/})
  apiarray=( $old )
    for apis in ${apiarray[@]}; do
    oldslash=$(echo ${apis////\\/})
    sed -i 's/'$oldslash'/'$new'/g' $4
  done

}

rtmp_ip_update() {
  # variables passed
  # $1 = webpage
  # $2 = javascript
  # $3 = urlUpdates

  # RTMP URL change
  old=$(cat $1 | grep -o rtmp.*:1935)
  new=rtmp:\\/\\/$(curl -s ifconfig.me):1935

  #array of rtmp entries
  rtmparray=( $old )
  for rtmp in ${rtmparray[@]}; do
    oldslash=$(echo ${rtmp////\\/})
    sed -i 's/'$oldslash'/'$new'/g' $1
  done

  old=$(cat $2 | grep -o rtmp.*:1935)
  new=rtmp:\\/\\/$(curl -s ifconfig.me):1935

  #array of rtmp entries
  rtmparray=( $old )
  for rtmp in ${rtmparray[@]}; do
    oldslash=$(echo ${rtmp////\\/})
    sed -i 's/'$oldslash'/'$new'/g' $2
  done
}

ffmpeg_reset() {
  # variables passed
  # $1 = urlUpdates

  ffmpegreset=$(cat $1 | jq -r '.FFmpegReset.reset')

  if [ $(echo $ffmpegreset) == "true" ]; then
    systemctl restart supervisord
    cat $1 | jq '.FFmpegReset.reset = "false"' > /tmp/urlUpdates; mv -f /tmp/urlUpdates $1
  fi
}

aws_acc_update() {
  # $1 javascript
  # $2 urlUpdates

  awsACC=$(cat $2 | jq -r '.Updates.awsACC')
  old=$(cat $1 | grep "const awsaccount" | cut -d "\"" -f 2 | tr -d "[:space:]")
  sed -i '0,/'$old'/s/'$old'/'$awsACC'/' $1
}

### functions end ###

### do some check on source urls
### hls should start with http* and end with *m3u8
hlsURL=$(cat $urlUpdates | jq -r '.Updates.hlsURL')

if [ $(echo $hlsURL | grep -o -c http.*m3u8) -eq 1 ]; then
  # the hls url is good
  hls_url_update $webpage $javascript $urlUpdates
else
  printf "hlsURL incorrect:"+$hlsURL
fi

### api gateway should start with http* and end with */eng
apiURL=$(cat $urlUpdates | jq -r '.Updates.apiURL')

if [ $(echo $apiURL | grep -o -c http.*/eng) -eq 1 ]; then
  # the api gateway url is good
  api_url_update $webpage $javascript $urlUpdates $dashboardsetup
else
  printf "apigwURL incorrect:" + apiURL
fi

#run aws acc number update
  awsACC=$(cat $urlUpdates | jq -r '.Updates.awsACC')
  if [ "$awsACC" -eq "$awsACC" ] 2>/dev/null || [ $(echo $awsACC | grep -c -o "master") -eq 1  ] 2>/dev/null; then
    aws_acc_update $javascript $urlUpdates
  else
    printf "AWS Account provided is not a number"
  fi

# run rtmp ip update
rtmp_ip_update $webpage $javascript $urlUpdates

# run ffmpeg streamer reset
ffmpeg_reset $urlUpdates

## end
