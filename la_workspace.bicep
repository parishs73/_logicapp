param location string

// Create a Log Analytics Workspace to store all logs
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'news-monitoring-workspace'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}
output  logAnalyticsWorkspaceId string =  logAnalyticsWorkspace.id
