param location string = resourceGroup().location

// Look up your existing workspace to tie the dashboard visualization directly to it
resource la_workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: 'news-monitoring-workspace'
}

resource monitoringDashboard 'Microsoft.Insights/workbooks@2023-06-01' = {
  name: guid('news-feeds-workbook', resourceGroup().id)
  location: location
  kind: 'shared'
  properties: {
    category: 'workbook'
    displayName: '📰 News Feeds Automation Dashboard'
    serializedData: string({
      version: 'Notebook/1.0'
      items: [
        {
          type: 1
          content: {
            json: '# 📰 RSS & Email Feed Telemetry\nUse this dashboard to monitor execution states, track delivery failure anomalies, and trace overall performance.'
          }
          name: 'title_banner'
        }
        {
          type: 3
          content: {
            version: 'KqlParameterItem/1.0'
            parameters: [
              {
                id: 'timeRange'
                type: 2
                description: 'Filter logs by time context'
                label: 'Time Range'
                required: true
                value: 'json:{"durationMs":86400000}' // Defaults to last 24 hours
                typeSettings: {
                  style: 'timeRange'
                }
              }
            ]
          }
          name: 'time_parameter'
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: 'AzureDiagnostics\r\n| where ResourceProvider == "MICROSOFT.LOGIC"\r\n| where Category == "WorkflowRuntime"\r\n| summarize \r\n    TotalRuns = count(), \r\n    Failures = countif(status_s == "Failed"), \r\n    Successes = countif(status_s == "Succeeded") \r\n  by Resource'
            size: 0 // Auto size grid layout
            timeContext: {
              durationMs: 86400000
            }
            timeContextFromParameter: 'timeRange'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
            crossComponentResources: [
              la_workspace.id
            ]
            visualization: 'table'
            gridSettings: {
              formatters: [
                {
                  columnMatch: 'Failures'
                  formatter: 18
                  formatOptions: {
                    thresholdsOptions: 'icons'
                    thresholdsGrid: [
                      { operator: '==', value: 0, representation: 'success' }
                      { operator: '>', value: 0, representation: 'error' }
                    ]
                  }
                }
              ]
            }
          }
          name: 'execution_summary_table'
        }
      ]
    })
  }
}
