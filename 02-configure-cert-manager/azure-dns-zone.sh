#!/bin/bash

# Get DNS zone in Azure for cert-manager. Resource group where the DNS zone is created.
RESOURCE_GROUP=openenv-bvmrc
ZONE_NAME=bvmrc.azure.redhatworkshops.io

# Make sure to replace <resource-group-name> and <hosted-zone-name> with your actual values"


# az group create --name $RESOURCE_GROUP --location northeurope

# Create the DNS zone
# az network dns zone create --resource-group $RESOURCE_GROUP  --name $ZONE_NAME

# Create Service Principal for DNS zone
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
az ad sp create-for-rbac --name sp-cert-manager \
  --role "DNS Zone Contributor" \
  --scopes "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/dnszones/$ZONE_NAME" \
  --sdk-auth

#Create secret with the SP credentials
TENANT_ID=$(az account show --query tenantId --output tsv)
CLIENT_ID=$(az ad sp list --display-name sp-cert-manager --query "[].appId" -o tsv)
SECRET_INFO=$(az ad app credential reset --id "$CLIENT_ID"  --append --display-name "auto-secret"  --years 1  --only-show-errors --output json)
CLIENT_SECRET=$(echo "$SECRET_INFO" | jq -r '.password')


oc create secret generic azuredns-config \
  --from-literal=clientSecret=$CLIENT_SECRET \
  --from-literal=clientID=$CLIENT_ID \
  --from-literal=tenantID=$TENANT_ID \
  --from-literal=subscriptionID=$SUBSCRIPTION_ID \
  -n cert-manager

cat << EOF > ./02-configure-cert-manager/ServicePrincipal-variables
export RESOURCE_GROUP=${RESOURCE_GROUP}
export SUBSCRIPTION_ID=${SUBSCRIPTION_ID}
export CLIENT_ID=${CLIENT_ID}
export TENANT_ID=${TENANT_ID}
EOF
