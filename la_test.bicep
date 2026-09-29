param location string = resourceGroup().location
param identityId string // Managed Identity with Reader access to the Resource Group

// OPTIONAL STAGE: If you are deploying Logic Apps in this same template, 
// deploy them here first. If they already exist, you can omit this step.
//module logicAppInfra './modules/logicApps.bicep' = {
  //name: 'logicAppInfraDeployment'
  //params: { location: location }
//}

// STAGE 2: Fetch the list of Logic Apps via Azure CLI
// 'dependsOn' ensures it runs AFTER your Logic Apps are fully created
resource fetchLogicAppsScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'fetchLogicAppsScript'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  dependsOn: [
  //  logicAppInfra // Forces the script to wait until Logic Apps are built
  ]
  properties: {
    azCliVersion: '2.60.0'
    timeout: 'PT5M'
    retentionInterval: 'P1D'
    environmentVariables: [
      { name: 'RG_NAME', value: resourceGroup().name }
    ]
    scriptContent: '''
      # Fetch all Logic Apps (workflows) in the current Resource Group and grab their names/IDs
      # Outputs a clean JSON array of strings or objects
      logicApps=$(az logic workflow list --resource-group "$RG_NAME" query "[].{name:name, id:id}" -o json)
      
      # Save the array to the deployment script output path
      echo "{\\"logicAppList\\": $logicApps}" > $AZ_SCRIPTS_OUTPUT_PATH
    '''
  }
}
