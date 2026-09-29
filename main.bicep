param connections_rss_name string = 'rss'
param connections_gmail_name string = 'gmail'
//param workflowName string = 'Consumption-logic-app-1'
param subscription_Id string = subscription().id
param location string = resourceGroup().location
//param rss_feed string ='https://feeds.content.dowjones.io/public/rss/RSSMarketsMain'
//param workflowNames array []


var news_feeds = [
   {
    name: 'la_DowJones_News'
    deploymentName: 'Dow_Jones_NEWS'
    feedUrl: 'https://feeds.content.dowjones.io/public/rss/RSSMarketsMain'
   }
  {
    name: 'la_Loreum_Test_Feed'
    deploymentName: 'Loreum_Test_Feed'
    feedUrl: 'https://lorem-rss.herokuapp.com/feed?unit=minute&interval30&length=2'
   }
   {
    name: 'la_BBC_News'
    deploymentName: 'BBC_NEWS'
    feedUrl: 'https://feeds.bbci.co.uk/news/world/rss.xml'
   }
/*   {
    name: 'la_News_NYTimes'
    deploymentName: 'NYTimes_News'
    feedUrl: 'https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml'

    }*/
    {
    name: 'la_News_CNN'
    deploymentName: 'CNN_News'
    feedUrl: 'http://rss.cnn.com/rss/cnn_topstories.rss'
    }
]

module connect_gmail 'connect_gmail.bicep' = {
  name: 'gmailSetup'
  params: {
    connections_gmail_name: connections_gmail_name
    location: location
    subscription_Id: subscription_Id

  }
}

module rss './connect_rss.bicep' = {
  name: 'rssConnector'
  params: {
    connections_rss_name: connections_rss_name
    subscription_Id: subscription_Id
    location: location
  }
}
module la_workspace './la_workspace.bicep' = {
  name: 'la_NewsLogic_analytics'
  params: {
    location: location
  }
}
module logicApps './workflow.bicep' = [ for feed in news_feeds:  {
  name: feed.deploymentName
  params: {
    location: location
    workflowName: feed.name
    subscription_Id: subscription_Id
    connections_rss_name_resourceId: rss.outputs.connections_rss_nameId
    connections_gmail_name_resourceId: connect_gmail.outputs.connections_gmail_nameId
    rss_feed: feed.feedUrl
  }
}]

module Diagnostics './diagnostics.bicep' = [for feed in news_feeds : {
  name: 'Diagnostics_${feed.deploymentName}'
  params:{
    workflowName: feed.name
    workspaceId: la_workspace.outputs.logAnalyticsWorkspaceId
  }
  dependsOn: [
    logicApps
  ]
}]


module workbook './workbook.bicep' = {
  name: 'First_Workbook'
  params:{
    location: location
    workspaceId: la_workspace.outputs.logAnalyticsWorkspaceId
  }
}

module workbook2 './workbook2.bicep' = {
  name: 'Second_Workbook'
  params:{
    location: location
    workspaceId: la_workspace.outputs.logAnalyticsWorkspaceId

  }
}
/*
module blockAi './blockai.bicep' = {
  name: 'Block_Ai'
  params: {
    location: location
    logAnalyticsWorkspaceId: la_workspace.outputs.logAnalyticsWorkspaceId
  }
}*/
/*
module DJLogicApp './workflow.bicep' = {
  name: 'la_DowJones_News'
  params: {
    location: location
    workflowName: 'Dow_Jones_NEWS'
    subscription_Id: subscription_Id
    connections_rss_name_resourceId: rss.outputs.connections_rss_nameId
    connections_gmail_name_resourceId: connect_gmail.outputs.connections_gmail_nameId
    rss_feed: 'https://feeds.content.dowjones.io/public/rss/RSSMarketsMain'
    logAnalyticWorkspaceId: la_workspace.outputs.logAnalyticsWorkspaceId
  }

}
module BBCNewsLogicApp './workflow.bicep' = {
  name: 'la_BBC_News'
  params: {
    location: location
    workflowName: 'BBC_NEWS'
    subscription_Id: subscription_Id
    connections_rss_name_resourceId: rss.outputs.connections_rss_nameId
    connections_gmail_name_resourceId: connect_gmail.outputs.connections_gmail_nameId
    rss_feed: 'http://bbci.co.uk'
    logAnalyticWorkspaceId: la_workspace.outputs.logAnalyticsWorkspaceId
  }

}

module NYTimesLogicApp './workflow.bicep' = {
  name: 'la_News_NYTimes'
  params: {
    location: location
    workflowName: 'NYTimes_News'
    subscription_Id: subscription_Id
    connections_rss_name_resourceId: rss.outputs.connections_rss_nameId
    connections_gmail_name_resourceId: connect_gmail.outputs.connections_gmail_nameId
    rss_feed: 'https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml'
    logAnalyticWorkspaceId: la_workspace.outputs.logAnalyticsWorkspaceId
  }
}

module CNNLogicApp './workflow.bicep' = {
  name: 'la_News_CNN'
  params: {
    location: location
    workflowName: 'CNN_News'
    subscription_Id: subscription_Id
    connections_rss_name_resourceId: rss.outputs.connections_rss_nameId
    connections_gmail_name_resourceId: connect_gmail.outputs.connections_gmail_nameId
    rss_feed: 'http://rss.cnn.com/rss/cnn_topstories.rss'
    logAnalyticWorkspaceId: la_workspace.outputs.logAnalyticsWorkspaceId
  }
}


module CNN_Diagnostics './Diagnostics.bicep' = {
  name: 'Diagnostics_CNN'
  params: {
    workflowName: CNNLogicApp.
    workspaceId: la_workspace.outputs.logAnalyticsWorkspaceId
  }
}

/*
module d './Diagnostics.bicep' = {
  name: 'Diagnostics'
  params: {
    workspaceId: la_workspace.outputs.logAnalyticsWorkspaceId
  }

}
  */

// (Assuming your workspace creation logic lives here or is passed in)


/*
module workflowDiagnosticsModule './Diagnostics.bicep' =  [for name in workflowNames: {
    name: 'Diagnostics-${name}'
    params: {
      workspaceId: logAnalyticsWorkspace.id
      workflowName: name
  }
}]
/*
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
  name: workflows_Consumption_logic_app_1_name
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
            id: '/subscriptions/574a07c8-b128-4a24-ac5f-1b8550b5a804/providers/Microsoft.Web/locations/southafricanorth/managedApis/gmail'
            connectionId: connections_gmail_name_resource.id
            connectionName: 'gmail'
            connectionProperties: {}
          }
        }
      }
    }
  }
}
  */
