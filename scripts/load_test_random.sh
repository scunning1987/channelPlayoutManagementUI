#!/bin/bash
#
#
#
# Arguments to be passed by user:
# /bin/bash [script_name] [device_quantity] [length_of_test_mins]
# Example: /bin/bash aim_load_test.sh 100 30
#

if [[ "$1" -lt 1 ]]  || [[ "$2" -lt 1 ]] || [[ "$3" -lt 1 ]]; then
echo ERROR: Please enter values for device quantity, test length *in minutes*, and child manifest curl interval
echo example: ./aim_load_test.sh 100 5 6
exit 0
fi
devices=$1
testduration=$2
requesturl="http://d3fch9e2fcarly.cloudfront.net/v1/master/94063eadf7d8c56e9e2edd84fdf897826a70d0df/testcampaign1/liveevent.m3u8"
baseurl=$(echo "${requesturl//v1*}")
###
#targetduration=` | grep TARGETDURATION | cut -d ":" -f 2 | tr -d '\r'`
targetduration=6
# "${requesturl%/*}"/$childplaylist?StreamType=LIVE
#
# Locations/Platforms: ( twitter facebook abcweb abcgo )
# while loop calculation: current_date_epoch + (length_of_test_mins * 60) = end_date_epoch; while end_date_epoch < current_date_epoch, run...
locationidarray=( ottm2 ottm3 ottm4 )
testdurationseconds=`expr $testduration \* 60`
iparray=( 174.216.3.31 174.21.67.91 73.106.73.47 73.43.180.100 66.108.37.65 172.58.231.219 172.58.23.153 35.187.132.37 17.45.127.218 76.16.14.173 24.217.60.255)
#
# Date Calculations
startdateepoch=`date -u +%s`
startdate=`date -d @$startdateepoch -u +%Y-%m-%dT%H:%M:%S`
enddateepoch=`expr "$startdateepoch" + "$testdurationseconds"`
enddate=`date -d @$enddateepoch -u +%Y-%m-%dT%H:%M:%S`
#
#
# Functions
#
# client_request_while_loop
client_request() {
# arguments
# $1 request_url
# $2 target_duration
# $3 end_date_epoch
# $4 ip
# $5 baseurl

variant=$(curl -s $1 | grep m3u8 | head -n 1 | cut -d "/" -f 4-);
childcurl=$(echo $5"v1"/$variant)

while [ `date -u +%s` -lt $3 ] ; do

  # curl
  curl -s -XGET "$childcurl?uid=1234" -H "X-Forwarded-For: $4" -H "User-Agent: loadtest" > /dev/null
  #curl -s -XGET "$childcurl" -H "X-Forwarded-For: $4"
  # sleep [target_duration]
  sleep $2

done

#echo Done testing : $childcurl $4
}
#
# 
# Functions End
echo `date -u +%Y-%m-%dT%H:%M:%S` : Test Starting, and will run for $testduration minutes...
for i in $(eval echo "{1..$devices}")
do
#ip address
ip=${iparray[`awk -v min=0 -v max=10 'BEGIN{srand(); print int(min+rand()*(max-min+1))}'`]}
#echo curl -XGET \"$request\&DeviceId=$deviceid\&LocationId=$locationid\" -H \"X-Forwarded-For: $ip\"

randomtestdur=`awk -v min=30 -v max=$testdurationseconds 'BEGIN{srand(); print int(min+rand()*(max-min+1))}'`
randomendtime=`expr "$startdateepoch" + "$randomtestdur"`

client_request $requesturl $targetduration $randomendtime $ip $baseurl &
#echo `date -u +%Y-%m-%dT%H:%M:%S` : Testing Device : $i
sleep 1s
done

