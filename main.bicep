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
