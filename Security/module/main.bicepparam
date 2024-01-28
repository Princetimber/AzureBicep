using './main.bicep'

param objectId = '' //TODO: Add the object id of the user that will be assigned the role
param tenantId = '' //TODO: Add the tenant id of the subscription
param publicIpAddress = '' //TODO: Add the public Ip Address of the local network.
param expirationDateInSeconds = 1737590400
param notBeforeDateInSeconds = 1706054398
param secretName = '' //TODO: Add the secret name for the admin passphrase
param secretValue = '' //TODO: Add the secret value for the admin passphrase
