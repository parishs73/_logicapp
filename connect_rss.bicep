param connections_rss_name string
param subscription_Id string
param location string

resource connectionsRss 'Microsoft.Web/connections@2016-06-01' = {
  name: connections_rss_name
  location: location
//  kind: 'V1'
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
      id: '${subscription_Id}/providers/Microsoft.Web/locations/${location}/managedApis/${connections_rss_name}'
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: []
  }
}
output connections_rss_nameId string = connectionsRss.id
