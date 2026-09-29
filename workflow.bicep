param workflowName string
param location string
param recipient string = 'simonparish5473@gmail.com'
param subscription_Id string
param connections_rss_name_resourceId string
param connections_gmail_name_resourceId string
param rss_feed string


resource workflows 'Microsoft.Logic/workflows@2019-05-01' = {
  name: workflowName
  location: location
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        When_a_feed_item_is_published: {
          recurrence: {
            interval: 30
            frequency: 'Minute'
            timeZone: 'GMT Standard Time'
            startTime: '2026-09-14T14:55:00Z'
          }
          evaluatedRecurrence: {
            interval: 30
            frequency: 'Minute'
            timeZone: 'GMT Standard Time'
            startTime: '2026-09-15T14:55:00Z'
          }
          splitOn: '@triggerBody()?[\'value\']'
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'rss\'][\'connectionId\']'
              }
            }
            method: 'get'
            path: '/OnNewFeed'
            queries: {
              feedUrl: '@{encodeURIComponent(\'${rss_feed}\')}'
              sinceProperty: 'PublishDate'
            }
          }
        }
      }
      actions: {
        'Send_email_(V2)': {
          runAfter: {}
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'gmail\'][\'connectionId\']'
              }
            }
            method: 'post'
            body: {
              To: recipient
              Subject: '[${workflowName}] - New RSS Item: @{triggerBody()?[\'title\']}'
              Body: '<p class="editor-paragraph">Title:@{triggerBody()?[\'title\']}<br>Published On:@{triggerBody()?[\'publishDate\']}</p><p class="editor-paragraph">Link: @{triggerBody()?[\'primaryLink\']}</p>'
            }
            path: '/v2/Mail'
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          rss: {
            id: '${subscription_Id}/providers/Microsoft.Web/locations/${location}/managedApis/rss'
            connectionId: connections_rss_name_resourceId
            connectionName: 'rss'
            connectionProperties: {}
          }
          gmail: {
            id: '${subscription_Id}/providers/Microsoft.Web/locations/${location}/managedApis/gmail'
            connectionId: connections_gmail_name_resourceId
            connectionName: 'gmail'
            connectionProperties: {}
          }
        }
      }
    }
  }
}


