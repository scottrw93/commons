#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters. First parameter should be the namespace, Second parameter should be the pod name"
fi
location=$(hs-kubectl exec -n $1 -it $2 -- /bin/bash -c "`cat k8s_heap_dump.sh`" | tail -n 1 | tr -d " \t\n\r" )
echo $location
hs-kubectl cp $1/$2:$location $(echo $location | awk -F '/' '{print $3}')
hs-kubectl exec -n $1 -it $2 -- /bin/bash -c "rm -f $location"

