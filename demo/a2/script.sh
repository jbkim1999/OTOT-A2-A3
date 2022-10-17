echo creating cluster
kind create cluster --name kind-1 --config ../../k8s/kind/cluster-config.yaml
kubectl get nodes

echo loading and deploying image to cluster
kind load docker-image a0194438u/node-web-app:latest --name kind-1
kubectl apply -f ../../k8s/manifests/k8s/node-deployment.yaml
kubectl get deployments

echo creating ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo creating service
kubectl apply -f ../../k8s/manifests/k8s/node-service.yaml
kubectl get services

sleep 30

echo resetting previous nginx-ingress-controller configuration
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission

echo creating ingress
kubectl apply -f ../../k8s/manifests/k8s/node-ingress.yaml
sleep 30
kubectl get ingress

echo visiting localhost:80
curl localhost/
