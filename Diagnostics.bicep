param workspaceId string
param workflowName string

resource targetLogicApp 'Microsoft.Logic/workflows@2019-05-01' existing = {
  name: workflowName
}

resource workflowDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'stream_to_log_analytics'
  scope: targetLogicApp
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'workflowRuntime'
        enabled: true
      }
    ]
  }
}
