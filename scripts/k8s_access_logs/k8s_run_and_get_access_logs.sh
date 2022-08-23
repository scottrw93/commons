#!/bin/bash
set -e


if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters. First parameter should be the namespace, Second parameter should be the pod name"
fi
hs-kubectl exec -n $1 -it $2 -- /bin/bash -c "`cat k8s_access_log_script.sh`"
hs-kubectl cp $1/$2:/app/logs/archive.tar archive.tar
