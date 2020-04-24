durationm=10
durations=$(( $durationm * 60 ))
rn=`awk -v min=60 -v max=$durations 'BEGIN{srand(); print int(min+rand()*(max-min+1))}'`
echo $rn

