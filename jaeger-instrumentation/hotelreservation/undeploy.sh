#!/bin/bash

APP_DIRECTORY=$1

APP_NAMESPACE=hotel-res

echo "\nDeleting client deployment"
kubectl -n $APP_NAMESPACE delete -f $APP_DIRECTORY/openshift/hr-client.yaml --ignore-not-found=true

echo "\nUninstalling application"
helm uninstall hotel-reservation --namespace $APP_NAMESPACE --ignore-not-found

echo "\nDeleting namespace"
kubectl delete namespace $APP_NAMESPACE --ignore-not-found=true

echo "\nDeleting persistent volumes"
deployments=("geo" "profile" "rate" "recommendation" "reservation" "user") 
for deployment in ${deployments[@]}; do
    kubectl delete persistentvolume/mongodb-$deployment-hotelreservation-pv --ignore-not-found=true
done