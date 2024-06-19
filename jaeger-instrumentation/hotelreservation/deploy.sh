#!/bin/bash

APP_DIRECTORY=$1

APP_NAMESPACE=hotel-res

FRONTEND_ENDPOINT=http://frontend-hotelreservation.$APP_NAMESPACE.svc.cluster.local:5000

JAEGER_AGENT_HOST=jaeger-hotelreservation.$APP_NAMESPACE.svc.cluster.local
JAEGER_AGENT_PORT=6831

JAEGER_COLLECTOR_HOST=instana-agent.instana-agent.svc.cluster.local
JAEGER_COLLECTOR_PORT=42699
JAEGER_COLLECTOR_ENDPOINT=http://$JAEGER_COLLECTOR_HOST:$JAEGER_COLLECTOR_PORT/com.instana.plugin.jaeger.trace

deploy_hotel_reservation_application() {
    echo "\ninstalling application"
    helm install hotelreservation --namespace $APP_NAMESPACE \
        --create-namespace \
        --set global.imagePullPolicy=Always \
        --set jaeger.container.imageVersion=latest \
        --set consul.container.imageVersion=1.15.7 \
        --set memcached-profile.container.imageVersion=latest \
        --set memcached-rate.container.imageVersion=latest \
        --set memcached-reserve.container.imageVersion=latest \
        $APP_DIRECTORY/helm-chart/hotelreservation

    deployments=("frontend" "geo" "profile" "rate" "recommendation" "reservation" "search" "user")
    
    echo "\nreplacing image and setting jaeger environment variables"
    for deployment in ${deployments[@]}; do
        kubectl -n $APP_NAMESPACE set env deployment/$deployment-hotelreservation \
            JAEGER_ENDPOINT=$JAEGER_COLLECTOR_ENDPOINT \
            JAEGER_SAMPLER_PARAM=0.9

        kubectl -n $APP_NAMESPACE rollout status "deployments/$deployment-hotelreservation" --timeout=600s
    done
}

create_hotel_reservation_client_deployment() {
    echo "\napplying hotel reservation deployment spec to cluster"
    kubectl -n $APP_NAMESPACE apply -f $APP_DIRECTORY/openshift/hr-client.yaml

    echo "\nwaiting for client to finish deploying"
    kubectl -n $APP_NAMESPACE rollout status "deployments/hr-client" --timeout=600s
    client=$(kubectl -n $APP_NAMESPACE get pod | grep hr-client | head -n 1 | awk '{print $1 }')

    echo "\ntransfering files to client pod"
    kubectl -n $APP_NAMESPACE cp $APP_DIRECTORY/wrk2/scripts $APP_NAMESPACE/$client:/root

    workload_file="/root/scripts/hotel-reservation/mixed-workload_type_1.lua"
    workload_cmd="wrk -D exp -t 5 -c 100 -d 60 -R 500 -L -s $workload_file $FRONTEND_ENDPOINT"
    echo "\nexecute the following command on the pod to run workload:"
    echo "kubectl -n $APP_NAMESPACE exec $client -- $workload_cmd"
}

deploy_hotel_reservation_application
create_hotel_reservation_client_deployment