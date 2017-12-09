#!/bin/bash

if [ -z "$1" ]; then echo "Cluster name not supplied"; exit 1; fi
CLUSTER_NAME=$1

read -s -p "Cluster Password:" CLUSTER_PASSWORD
echo

RG_LOCATION=northeurope # Change it when ADLS is publicly available in West Europe

# Login if necessary
if [[ $(az account show) != *tenantId* ]]; then az login; fi

# Select Azure subscription if you have multiple of them
# az account set --subscription <SUBSCRIPTION_ID>

# Create Service Principal with certificate
# Certificate is not created if Service Principal already exists
PEM_FILE=$(az ad sp create-for-rbac --name $CLUSTER_NAME --create-cert --query "fileWithCertAndPrivateKey" -o tsv)
echo "$PEM_FILE"

# Export pem to pfx with password
if [[ $PEM_FILE == *.pem ]]
then
    openssl pkcs12 -export <$PEM_FILE -out $CLUSTER_NAME.pfx -password pass:$CLUSTER_PASSWORD
    rm -rf $PEM_FILE
fi

CERT_BASE64=$(base64 $CLUSTER_NAME.pfx)
if [[ -z "$CERT_BASE64" ]]
then
    echo "Please provide $CLUSTER_NAME.pfx or delete existing Service Principal and retry!"
    exit 1
fi

# Extract Service Principal Metadata
SP_APPID=$(az ad sp list --display-name $CLUSTER_NAME --query "[0].appId" -o tsv)
SP_OBJECTID=$(az ad sp list --display-name $CLUSTER_NAME --query "[0].objectId" -o tsv)
AAD_TENANT=$(az account show --query "tenantId" -o tsv)

# Create resource group
az group create -n $CLUSTER_NAME -l $RG_LOCATION

# Deploy!
az group deployment create -g $CLUSTER_NAME --template-file azuredeploy.json --debug --parameters\
    clusterPassword="$CLUSTER_PASSWORD" \
    aadTenantId=$AAD_TENANT \
    servicePrincipalObjectId=$SP_OBJECTID \
    servicePrincipalApplicationId=$SP_APPID \
    servicePrincipalCertificateContents="$CERT_BASE64"