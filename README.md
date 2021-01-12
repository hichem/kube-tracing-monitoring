# ELK + Prometheus/Grafana Local Deployment on Minikube

The following source code deploys ELK and Prometheus/Grafana Stacks on Minikube using Terraform.

## Prerequisites

Install the following software on the local machine:
* Docker (Docker Desktop on Windows)
* Minikube
* Terraform

## Start Minikube

Run the following command:

~~~
minikube start
~~~

Alternatively (to require more resources)

~~~
minikube start --cpus 4 --memory 3064 --bootstrapper=kubeadm --extra-config=scheduler.address=0.0.0.0 --extra-config=controller-manager.address=0.0.0.0
~~~

## Install ELK & Prometheus/Grafana

Move to terraform directory

~~~
cd terraform
~~~

Initialize terraform providers

~~~
terraform init
~~~

Apply Terraform configuration. By default, terraform will connect to the local kubernetes cluster (minikube) using the config file
created in the home directory (~/.kube/config)

~~~
terraform apply
~~~

## Expose ELK + Prometheus/Grafana Services

Expose the ELK and Prometheus/Grafana services using the command below in order to be able to access them from local machine:

~~~
minikube service grafana -n monitoring
minikube service prometheus-server -n monitoring
minikube service logstash -n tracing
minikube service kibana -n tracing
~~~
