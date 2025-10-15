#Install cert-manager and configure it for OpenShift
#Azure Variables
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId --output tsv)
CLIENT_ID=$(az ad sp list --display-name sp-cert-manager --query "[].appId" -o tsv)

echo "Installing cert-manager and configuring it for OpenShift..."
#/01-install-operator/install-cert-manager.sh

echo "Enabling DNS zone for cert-manager in Azure..."
./02-configure-cert-manager/azure-dns-zone.sh
# echo "DNS zone created successfully."

#Create cert manager
oc apply -f 02-configure-cert-manager/cert-manager-cluster.yaml
echo "Cert Manager Cluster successfully created."

#Create cluster-issuer

source ./02-configure-cert-manager/ServicePrincipal-variables
envsubst < 02-configure-cert-manager/cluster-issuer-tmp.yaml > 02-configure-cert-manager/cluster-issuer.yaml

oc apply -f 02-configure-cert-manager/cluster-issuer.yaml
echo "Cluster Issuer successfully created."

#Create certificates for api and ingress
#oc apply -f 02-configure-cert-manager/certificate-api.yaml
#oc apply -f 02-configure-cert-manager/certificate-ingress.yaml

#echo "Certificates for API and Ingress successfully created."

# Update the default certificate for the ingress controller
#oc apply -f 02-configure-cert-manager/ingress-controller.yaml 

#echo "Default certificate for the ingress controller updated."

# Create APIserver for the API certificate
#oc apply -f 02-configure-cert-manager/apiserver-cert.yaml
#echo "APIServer for the API certificate successfully updated."
