group=azure-demo-arvind-datamanagement
az group create -g $group -l eastus
username=masteruser$RANDOM
password='passkey~!@#'$RANDOM

az network vnet create \
  -n vm-vnet \
  -g $group \
  -l eastus \
  --address-prefixes '192.168.0.0/16' \
  --subnet-name subnet \
  --subnet-prefixes '192.168.1.0/24'

az vm create \
  -n vm-sql \
  -g $group \
  -l eastus \
  --size standard_ds3_v2 \
  --image MicrosoftSQLServer:SQL2017-WS2016:Standard:latest \
  --admin-username $username \
  --admin-password $password \
  --vnet-name vm-vnet \
  --subnet subnet \
  --public-ip-address ""

az vm open-port -g $group --name vm-sql --port 1433

az sql vm create \
  -n vm-sql \
  -g $group \
  -l eastus \
  --license-type PAYG \
  --connectivity-type PRIVATE \
  --sql-mgmt-type Full \
  --sql-auth-update-username $username \
  --sql-auth-update-pwd $password \
  --port 1433

az vm create \
  -n vm-selfhostedir \
  -g $group \
  -l eastus \
  --size standard_ds3_v2 \
  --image Win2019Datacenter \
  --admin-username $username \
  --admin-password $password \
  --vnet-name vm-vnet \
  --subnet subnet \
  --nsg-rule rdp 

az storage account create \
  -n adfirstorage$RANDOM$RANDOM \
  -g $group \
  -l eastus

az vm list \
  -g $group -d \
  --query "[].{name:name,publicIps:publicIps,privateIps:privateIps,user:osProfile.adminUsername,password:'$password'}" \
  -o jsonc > clouddrive/$group.json
  
cat clouddrive/$group.json