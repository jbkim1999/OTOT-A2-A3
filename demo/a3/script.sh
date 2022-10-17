echo ----- deleting existing cluster -----
kind delete cluster --name kind-1

sleep 30

echo ----- creating cluster ----- 
kind create cluster --name kind-1 --config ../../k8s/kind/cluster-config.yaml
kubectl get nodes

echo ----- loading and deploying image to cluster, zone-aware ----- 
kind load docker-image a0194438u/node-web-app:latest --name kind-1
kubectl apply -f ../../k8s/manifests/k8s/node-deployment-zone-aware.yaml
kubectl get deployments

echo ----- creating ingress controller ----- 
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo ----- creating service ----- 
kubectl apply -f ../../k8s/manifests/k8s/node-service.yaml
kubectl get services

sleep 30

echo ----- resetting previous nginx-ingress-controller configuration -----
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission

echo ----- creating ingress ----- 
kubectl apply -f ../../k8s/manifests/k8s/node-ingress.yaml
sleep 30
kubectl get ingress

echo ----- setting up metrics-server ----- 
kubectl apply -f ../../k8s/manifests/k8s/metrics-server.yaml

echo ----- creating horizontal pod autoscaler ----- 
kubectl apply -f ../../k8s/manifests/k8s/node-hpa.yaml
kubectl describe hpa

echo ---- getting pods -----
kubectl get pods

echo ----- conducting stress test -----
seq 1 10000 | xargs -n1 -P100 curl --silent --output /dev/null "http://localhost:80"
sleep 10

echo ----- getting pods to see more pods fired -----
kubectl get pods

echo ----- checking zone-awareness ----- 
kubectl get nodes -L topology.kubernetes.io/zone
kubectl get po -lapp=node -owide --sort-by='.spec.nodeName'
