duration=$1
if [ $duration == "15" ]; then
curl -v https://vq039s9t6d.execute-api.us-west-2.amazonaws.com/default/scte3515second
elif [ $duration == "30" ]; then
curl -v https://idyoj2l0l2.execute-api.us-west-2.amazonaws.com/default/scte35Inject
else
curl -v https://vd4t595094.execute-api.us-west-2.amazonaws.com/default/scte3560second
fi
