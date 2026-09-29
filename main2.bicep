param connections_rss_name string = 'rss'
param connections_gmail_name string = 'gmail'
param workflowName string = 'Consumption-logic-app-1'
param subscriptionId string = subscription().id
param location string = resourceGroup().location
param rss_feed string ='https://feeds.content.dowjones.io/public/rss/RSSMarketsMain'


resource connections_gmail_name_resource 'Microsoft.Web/connections@2016-06-01' = {
  name: connections_gmail_name
  location: 'southafricanorth'
  kind: 'V1'
  properties: {
    displayName: 'Google send email'
    statuses: [
      {
        status: 'Connected'
      }
    ]
    customParameterValues: {}
    createdTime: '2026-09-14T14:04:08.5186504Z'
    changedTime: '2026-09-14T14:04:36.2833525Z'
    api: {
      name: connections_gmail_name
      displayName: 'Gmail'
      description: 'Gmail is a web-based email service from Google. With the Gmail connector, you can perform actions such as send or receive e-mail messages, and trigger flows on new e-mails.'
      iconUri: 'https://static.powerapps.com/resource/ppcr/releases/v1.0.1819/1.0.1819.4795/${connections_gmail_name}/icon.png'
      id: '/subscriptions/574a07c8-b128-4a24-ac5f-1b8550b5a804/providers/Microsoft.Web/locations/southafricanorth/managedApis/${connections_gmail_name}'
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: [
      {
        requestUri: 'https://management.azure.com:443/subscriptions/574a07c8-b128-4a24-ac5f-1b8550b5a804/resourceGroups/logic-rg/providers/Microsoft.Web/connections/${connections_gmail_name}/extensions/proxy/TestConnection?api-version=2016-06-01'
        method: 'get'
      }
    ]
  }
}

resource connections_rss_name_resource 'Microsoft.Web/connections@2016-06-01' = {
  name: connections_rss_name
  location: 'southafricanorth'
  kind: 'V1'
  properties: {
    displayName: 'RSS'
    statuses: [
      {
        status: 'Connected'
      }
    ]
    customParameterValues: {}
    nonSecretParameterValues: {}
    createdTime: '2026-09-14T13:47:35.9834489Z'
    changedTime: '2026-09-14T13:47:38.9001383Z'
    api: {
      name: connections_rss_name
      displayName: 'RSS'
      description: 'RSS is a popular web syndication format used to publish frequently updated content – like blog entries and news headlines.  Many content publishers provide an RSS feed to allow users to subscribe to it.  Use the RSS connector to retrieve feed information and trigger flows when new items are published in an RSS feed.'
      iconUri: 'https://static.powerapps.com/resource/ppcr/releases/v1.0.1827/1.0.1827.4925/${connections_rss_name}/icon.png'
      brandColor: '#ff9900'
      id: '/subscriptions/574a07c8-b128-4a24-ac5f-1b8550b5a804/providers/Microsoft.Web/locations/southafricanorth/managedApis/${connections_rss_name}'
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: []
  }
}

resource workflows_Consumption_logic_app_1_name_resource 'Microsoft.Logic/workflows@2017-07-01' = {
  name: 'workflows_Consumption_logic_app_1_name'
  location: 'southafricanorth'
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
            startTime: '2026-09-14T14:55:00Z'
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
              feedUrl: '@{encodeURIComponent(\'https://feeds.content.dowjones.io/public/rss/RSSMarketsMain\')}'
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
              To: 'simonparish5473@gmail.com'
              Subject: 'New RSS Item: @{triggerBody()?[\'title\']}'
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
            id: '/subscriptions/574a07c8-b128-4a24-ac5f-1b8550b5a804/providers/Microsoft.Web/locations/southafricanorth/managedApis/rss'
            connectionId: connections_rss_name_resource.id
            connectionName: 'rss'
            connectionProperties: {}
          }
          gmail: {
            id: 'subscriptions/574a07c8-b128-4a24-ac5f-1b8550b5a804/providers/Microsoft.Web/locations/southafricanorth/managedApis/gmail'
            connectionId: connections_gmail_name_resource.id
            connectionName: 'gmail'
            connectionProperties: {}
          }
        }
      }
    }
  }
}
