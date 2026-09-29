@description('The friendly name for the workbook that is used in the Gallery or Saved List.  This name must be unique within a resource group.')
param workbookDisplayName string = 'New Test Workbook'

@description('The gallery that the workbook will been shown under. Supported values include workbook tsg etc. Usually this is \'workbook\'')
param workbookType string = 'workbook'

@description('The id of resource instance to which the workbook will be associated')
//param workbookSourceId string = '/subscriptions/574a07c8-b128-4a24-ac5f-1b8550b5a804/resourceGroups/logic-app/providers/Microsoft.OperationalInsights/workspaces/news-monitoring-workspace'
param rgName string = resourceGroup().name
param workspaceId string
//@description('The unique guid for this workbook instance')
//param workbookId string = newGuid()

param location string

resource workbook_name 'Microsoft.Insights/workbooks@2023-06-01' = {
  name: guid('-bob2')
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
            crossComponentResources: [
             workspaceId
            ]
            stickySettings: {
              isSticky: true
            }
            parameters: [
              {
                version: 'KqlParameterItem/1.0'
                name: 'RSS_Feed'
                type: 2
                isRequired: true
                query: $'''AzureDiagnostics
                          | where ResourceGroup == toupper("${rgName}")
                          | summarize by RSS_Feed = resource_workflowName_s
                          | order by RSS_Feed asc'''
                crossComponentResources: [
                  workspaceId
                ]
                typeSettings: {
                  additionalResourceOptions: [
                    'value::all'
                  ]
                  selectAllValue: '*'
                  showDefault: false
                }
                timeContext: {
                  durationMs: 86400000
                }
                queryType: 0
                resourceType: 'microsoft.operationalinsights/workspaces'
                value: 'value::all'
              }

              {
                version: 'KqlParameterItem/1.0'
                name: 'TimeRange'
                isRequired: true
                type: 4
                typeSettings: {
                  selectableValues: [
                    {
                      durationMs: 300000
                    }
                    {
                      durationMs: 900000
                    }
                    {
                      durationMs: 1800000
                    }
                    {
                      durationMs: 3600000
                    }
                    {
                      durationMs: 14400000
                    }
                    {
                      durationMs: 43200000
                    }
                    {
                      durationMs: 86400000
                    }
                    {
                      durationMs: 172800000
                    }
                    {
                      durationMs: 259200000
                    }
                    {
                      durationMs: 604800000
                    }
                    {
                      durationMs: 1209600000
                    }
                    {
                      durationMs: 2419200000
                    }
                    {
                      durationMs: 2592000000
                    }
                    {
                      durationMs: 5184000000
                    }
                    {
                      durationMs: 7776000000
                    }
                  ]
                }
                value: {
                  durationMs: 14400000
                }
              }
            ]
            style: 'pills'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
          }
          name: 'TimeRange-dropdown'
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: '''union withsource=["$TableName"] *
            | where "{RSS_Feed}" in ("*", "",  "All") or resource_workflowName_s == "{RSS_Feed}"
            | summarize Count=count() by TableName=["$TableName"], bin(TimeGenerated, 1h)
            | render barchart'''
            size: 1
            timeContextFromParameter: 'TimeRange'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
          }

          name: 'query - 2'
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: '''union withsource=["$TableName"] *
                      | where "{RSS_Feed}" in ("*", "",  "All") or resource_workflowName_s == "{RSS_Feed}"
                      | summarize Count=count() by TableName=["$TableName"], bin(TimeGenerated, 1h)
                      | render timechart'''
            size: 1
            timeContextFromParameter: 'TimeRange'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
          }

          name: 'query - 3 time chart'
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: '''AzureDiagnostics
             | where "{RSS_Feed}" in ("*", "",  "All") or resource_workflowName_s == "{RSS_Feed}"
            | where ResourceProvider == "MICROSOFT.LOGIC"
            | where Category == "WorkflowRuntime"
            | where OperationName == "Microsoft.Logic/workflows/workflowRunCompleted"
            | summarize TotalRuns = count() by Name = resource_workflowName_s
            | order by TotalRuns desc'''
            size: 0
            timeContextFromParameter: 'TimeRange'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
          }

          name: 'query - 2'
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: '''AzureDiagnostics
                     | where "{RSS_Feed}" in ("*", "",  "All") or resource_workflowName_s == "{RSS_Feed}"
                     | where ResourceProvider == "MICROSOFT.LOGIC"
                     | where Category == "WorkflowRuntime"
                     | where OperationName == "Microsoft.Logic/workflows/workflowRunCompleted"
                     // 1. Calculate duration in seconds (if not explicitly provided as duration_d)
                     | extend DurationSec = (endTime_t - startTime_t) / 1s
                     // 2. Identify the status of the run
                     | extend Status = status_s
                     // 3. Aggregate metrics per Logic App
                     | summarize 
                        TotalRuns = count(),
                        Succeeded = countif(Status == "Succeeded"),
                        FailedRuns = countif(Status == "Failed"),
                        CancelledRuns = countif(Status == "Cancelled"),
                        SlowRuns = countif(DurationSec > 5), // Adjust \'5\' to your threshold in seconds
                        AvgDurationSec = round(avg(DurationSec), 3) //3 decimal places
                        by LogicAppName = resource_workflowName_s
                     | order by FailedRuns desc, SlowRuns desc
                     '''
            size: 0
            timeContextFromParameter: 'TimeRange'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
          }

          name: 'query - 3'
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: '''AzureDiagnostics 
                     | where "{RSS_Feed}" in ("*", "",  "All") or resource_workflowName_s == "{RSS_Feed}"
                      | where ResourceProvider == "MICROSOFT.LOGIC"
                      | where Category == "WorkflowRuntime"
                      | summarize
                          Total = count() by status_s, resource_workflowName_s, OperationName'''
            size: 0
            timeContextFromParameter: 'TimeRange'
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
