@description('The friendly name for the workbook that is used in the Gallery or Saved List.  This name must be unique within a resource group.')
param workbookDisplayName string = 'Simon\'s Unsaved Workbook'

@description('The gallery that the workbook will been shown under. Supported values include workbook, tsg, etc. Usually, this is \'workbook\'')
param workbookType string = 'workbook'

@description('The id of resource instance to which the workbook will be associated')
//param workbookSourceId string = '/subscriptions/574a07c8-b128-4a24-ac5f-1b8550b5a804/resourceGroups/logic-app/providers/Microsoft.OperationalInsights/workspaces/news-monitoring-workspace'
param workspaceId string
//@description('The unique guid for this workbook instance')
//param workbookId string = newGuid()

param location string

resource workbook_name 'Microsoft.Insights/workbooks@2023-06-01' = {
  name: guid('-bob')
  identity: {
    type: 'None'
  }
  location: location
  kind: 'shared'
  properties: {
    displayName: workbookDisplayName
    serializedData: string({
      version: 'Notebook/1.0'
      items: [
        {
          type: 1
          content: {
            json: '## New workbook\n---\n\nWelcome to your new workbook.  This area will display text formatted as markdown.\n\n\nWe\'ve included a basic analytics query to get you started. Use the `Edit` button below each section to configure it or add more sections.'
          }
          name: 'text - 2'
        }
        {
          type: 9
          content: {
            version: 'KqlParameterItem/1.0'
            parameters: [
              {
                id: 'SelectedWorkflow'
                type: 2
                description: 'Select a Logic App Workflow'
                isRequired: true
                query: 'AzureDiagnostics | where ResourceProvider == "MICROSOFT.LOGIC" and Category == "WorkflowRuntime" | summarize by resource_workflowName_s | order by resource_workflowName_s asc'
                crossComponentTransactionHint: 'inline'
                value: 'All'
                typeSettings: {
                  additionalResourceOptions: [
                    'value::1'
                  ]
                  showDefaultSettings: false
                }
                queryType: 0
                resourceType: 'microsoft.operationalinsights/workspaces'
              }
            ]
          }
          name: 'workflow-dropdown'
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: 'union withsource=["\$TableName"] *\n| summarize Count=count() by TableName=["\$TableName"]\n| render barchart'
            size: 1
            timeContext: {
              durationMs: 14400000 //last 4hrs
            }
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
          }
          name: 'query - 2'
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: 'union withsource=["\$TableName"] *\n| summarize Count=count() by TableName=["\$TableName"], bin(TimeGenerated, 1h)\n| render timechart'
            size: 1
            timeContext: {
              durationMs: 14400000 //last 4hrs
            }
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
          }
          name: 'query - 3 time chart'
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: 'AzureDiagnostics\r\n| where ResourceProvider == "MICROSOFT.LOGIC"\r\n| where Category == "WorkflowRuntime"\r\n| where OperationName == "Microsoft.Logic/workflows/workflowRunCompleted"\r\n| summarize TotalRuns = count() by Name = resource_workflowName_s\r\n| order by TotalRuns desc\r\n'
            size: 0
            timeContext: {
              durationMs: 14400000 //Last 4hrs
            }
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
          }
          name: 'query - 2'
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: 'AzureDiagnostics\r\n| where ResourceProvider == "MICROSOFT.LOGIC"\r\n| where Category == "WorkflowRuntime"\r\n| where OperationName == "Microsoft.Logic/workflows/workflowRunCompleted"\r\n// 1. Calculate duration in seconds (if not explicitly provided as duration_d)\r\n| extend DurationSec = (endTime_t - startTime_t) / 1s\r\n// 2. Identify the status of the run\r\n| extend Status = status_s\r\n// 3. Aggregate metrics per Logic App\r\n| summarize \r\n    TotalRuns = count(),\r\n    Succeeded = countif(Status == "Succeeded"),\r\n    FailedRuns = countif(Status == "Failed"),\r\n    CancelledRuns = countif(Status == "Cancelled"),\r\n    SlowRuns = countif(DurationSec > 5), // Adjust \'5\' to your threshold in seconds\r\n    AvgDurationSec = avg(DurationSec)\r\n    by LogicAppName = resource_workflowName_s\r\n| order by FailedRuns desc, SlowRuns desc\r\n'
            size: 0
            timeContext: {
              durationMs: 86400000
            }
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
          }
          name: 'query - 3'
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: 'AzureDiagnostics \r\n| where ResourceProvider == "MICROSOFT.LOGIC"\r\n| where Category == "WorkflowRuntime"\r\n| summarize\r\n    Total = count() by status_s, resource_workflowName_s, OperationName'
            size: 0
            timeContext: {
              durationMs: 86400000 //24hrs
            }
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
          }
          name: 'query - 4'
        }
      ]
      isLocked: false
      fallbackResourceIds: [
        workspaceId
        //'/subscriptions/574a07c8-b128-4a24-ac5f-1b8550b5a804/resourceGroups/logic-app/providers/Microsoft.OperationalInsights/workspaces/news-monitoring-workspace'
      ]
    })
    version: '1.0'
    sourceId: workspaceId
    category: workbookType
  }
  dependsOn: []
}

output workbookId string = workbook_name.id
