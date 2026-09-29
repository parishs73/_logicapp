param location string = 'location'
param logAnalyticsWorkspaceId string 

resource blockAi 'Microsoft.Monitor/observabilityAgents@2026-05-01-preview' = {
  name: 'default'
  location: location
  properties:{
    monitoringAccountId: logAnalyticsWorkspaceId
    enabled: true
        operations: [
      {
        type: 'Investigation'
        mode: 'Manual' // Changes from Auto to Manual to stop background charges
      }
      {
        type: 'IssueCreation'
        mode: 'Manual'
      }
    ]
  }
}
