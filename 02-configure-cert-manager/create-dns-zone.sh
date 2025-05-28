#!/bin/bash

# Create a DNS zone in Azure for cert-manager
RESOURCE_GROUP="rg-dns"
ZONE_NAME="amaroton.pmfw2.azure.redhatworkshops.io"

az group create --name $RESOURCE_GROUP --location westeurope

# Create the DNS zone
az network dns zone create --resource-group $RESOURCE_GROUP  --name $ZONE_NAME

# Create Service Principal for DNS zone
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
az ad sp create-for-rbac --name sp-cert-manager \
  --role "DNS Zone Contributor" \
  --scopes "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/dnszones/$ZONE_NAME" \
  --sdk-auth

#Create secret with the SP credentials
TENANT_ID=$(az account show --query tenantId --output tsv)
CLIENT_ID=$(az ad sp list --display-name sp-cert-manager --query "[].appId" -o tsv)
CLIENT_SECRET=$(az ad sp credential list --id $CLIENT_ID --query "[0].value" -o tsv)

oc create secret generic azuredns-config \
  --from-literal=clientSecret=$CLIENT_SECRET \
  --from-literal=clientID=$CLIENT_ID \
  --from-literal=tenantID=$TENANT_ID \
  --from-literal=subscriptionID=$SUBSCRIPTION_ID \
  -n cert-manager
