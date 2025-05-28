#Install cert-manager and configure it for OpenShift
./../01-install-operator/install-cert-manager.sh

#Create DNS zone for cert-manager in Azure
./create-dns-zone.sh

#Create cert manager
oc apply -f cert-manager-cluster.yaml

#Create cluster-issuer
oc apply -f cluster-issuer.yaml

#Create certificates for api and ingress
oc apply -f certificate-api.yaml
oc apply -f certificate-ingress.yaml

# Update the default certificate for the ingress controller
oc patch ingresscontroller default -n openshift-ingress-operator \
  --type=merge \
  -p '{
    "spec": {
      "defaultCertificate": {
        "name": "ocp-ingress"
      }
    }
  }'


# Create APIserver for the API certificate
oc apply -f apiserver-cert.yaml
