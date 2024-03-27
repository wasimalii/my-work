#!/bin/bash
managedinstances=$(/home/wasimali/google-cloud-sdk/bin/gcloud compute instance-groups managed list --filter=autoscaled=yes | awk '{print $1}' | tail -n +2)

for i in ${managedinstances[@]}; do
	check=$(/home/wasimali/google-cloud-sdk/bin/gcloud compute instance-groups managed describe $i --format="flattened(autoscaler.autoscalingPolicy.maxNumReplicas,targetSize)" | cut -d ":" -f 2)
	checkmaxrpl=$(echo $check | cut -d ' ' -f 1)
	checktarget=$(echo $check | cut -d ' ' -f 2)

	result=$(echo "$checkmaxrpl/100*60" | bc -l)
	intform=$(printf '%.0f\n' $result)

	if (($checktarget >= $intform)); then
	/usr/bin/curl \
    -X POST \
    -s \
    --data-urlencode "payload={ \
        \"channel\": \"#monit-monitoring-logs\", \
        \"username\": \"Gcloud Load Balancer\", \
        \"pretext\": \"Trackier | Google Cloud Load Balancer | $i\", \
        \"color\": \"danger\", \
        \"text\": \"Load Balancer ($i) has reached 60 Percent Capacity.\" \
    }" \
    https://hooks.slack.com/services/T1NLV2ABU/hddxyzyvsd5/773bdd6
	fi
done
