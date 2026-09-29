param location string
param connections_gmail_name string
param subscription_Id string

var managementURL = environment().resourceManager

resource connectionsGmail 'Microsoft.Web/connections@2016-06-01' = {
  name: connections_gmail_name
  location: location
//  kind: 'V1'
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
      id: '${subscription_Id}/providers/Microsoft.Web/locations/${location}/managedApis/${connections_gmail_name}'
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: [
      {
        requestUri: uri(managementURL, '${subscription_Id}/resourceGroups/logic-rg/providers/Microsoft.Web/connections/${connections_gmail_name}/extensions/proxy/TestConnection?api-version=2016-06-01')
        method: 'get'
      }
    ]
  }
}
output connections_gmail_nameId string = connectionsGmail.id
