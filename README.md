# AzureExamples
## APIM Example

### single tenant example (Entra)
```
<policies>
  <inbound>
        <validate-azure-ad-token tenant-id="{Tenant-ID}">
            <client-application-ids>
                <application-id>{Application ID}</application-id>
            </client-application-ids>
        </validate-azure-ad-token>
  </inbound>
  <backend>
    <!-- statements to be applied before the request is forwarded to 
         the backend service go here -->
  </backend>
  <outbound>
    <!-- statements to be applied to the response go here -->
  </outbound>
  <on-error>
    <!-- statements to be applied if there is an error condition go here -->
  </on-error>
</policies> 
```

### multiple specified tenants example

```
<choose>
    <when condition="@(context.Request.Headers.GetValueOrDefault('Authorization', '').Split(' ').ElementAtOrDefault(1).AsJwt().Claims['tid'].FirstOrDefault() == 'tenant-id-1')">
        <validate-azure-ad-token tenant-id="tenant-id-1" header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Invalid token">
            <audiences>
                <audience>api://your-api-id</audience>
            </audiences>
            <client-application-ids>
                <application-id>{Application ID}</application-id>
            </client-application-ids>
        </validate-azure-ad-token>
    </when>
    <when condition="@(context.Request.Headers.GetValueOrDefault('Authorization', '').Split(' ').ElementAtOrDefault(1).AsJwt().Claims['tid'].FirstOrDefault() == 'tenant-id-2')">
        <validate-azure-ad-token tenant-id="tenant-id-2" header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Invalid token">
            <audiences>
                <audience>api://your-api-id</audience>
            </audiences>
            <client-application-ids>
                <application-id>{Application ID}</application-id>
            </client-application-ids>
        </validate-azure-ad-token>
    </when>
    <when condition="@(context.Request.Headers.GetValueOrDefault('Authorization', '').Split(' ').ElementAtOrDefault(1).AsJwt().Claims['tid'].FirstOrDefault() == 'tenant-id-3')">
        <validate-azure-ad-token tenant-id="tenant-id-3" header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Invalid token">
            <audiences>
                <audience>api://your-api-id</audience>
            </audiences>
            <client-application-ids>
                <application-id>{Application ID}</application-id>
            </client-application-ids>
        </validate-azure-ad-token>
    </when>
    <otherwise>
        <return-response>
            <set-status code="401" reason="Unauthorized" />
            <set-body>Invalid token</set-body>
        </return-response>
    </otherwise>
</choose>

```


### multi-tenant example (Entra)
```
<policies>
  <inbound>
        <validate-azure-ad-token tenant-id="organizations">
            <client-application-ids>
                <application-id>{Application ID}</application-id>
            </client-application-ids>
        </validate-azure-ad-token>
  </inbound>
  <backend>
    <!-- statements to be applied before the request is forwarded to 
         the backend service go here -->
  </backend>
  <outbound>
    <!-- statements to be applied to the response go here -->
  </outbound>
  <on-error>
    <!-- statements to be applied if there is an error condition go here -->
  </on-error>
</policies> 
```


### single auth endpoint (JWT)
```
<policies>
  <inbound>
    <validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized. Invalid token." require-expiration-time="true" require-scheme="Bearer" require-signed-tokens="true">
        <openid-config url="https://login.microsoftonline.com/{tenant-id}/v2.0/.well-known/openid-configuration" />
        <audiences>
          <audience>{client-id}</audience>
        </audiences>
  </validate-jwt>

  </inbound>
  <backend>
    <!-- statements to be applied before the request is forwarded to 
         the backend service go here -->
  </backend>
  <outbound>
    <!-- statements to be applied to the response go here -->
  </outbound>
  <on-error>
    <!-- statements to be applied if there is an error condition go here -->
  </on-error>
</policies> 
```

### Multiple specified Auth endpoints
```
<policies>
  <inbound>
    <set-variable name="iss" value="@(context.Request.Headers.GetValueOrDefault('Authorization', '')?.Split(' ')?.ElementAtOrDefault(1)?.AsJwt()?.Claims['iss']?.FirstOrDefault() ?? '')" />
    <choose>
        <when condition="@(context.Variables.GetValueOrDefault('iss', '').Equals('https://login.microsoftonline.com/{tenant01-id}/v2.0'))">
          <validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized. Invalid token." require-expiration-time="true" require-scheme="Bearer" require-signed-tokens="true">
            <openid-config url="https://issuer1.com/.well-known/openid-configuration" />
            <audiences>
              <audience>{tenant01-client-id}</audience>
            </audiences>
          </validate-jwt>
        </when>
        <when condition="@(context.Variables.GetValueOrDefault('iss', '').Equals('https://login.microsoftonline.com/{tenant02-id}/v2.0'))">
          <validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized. Invalid token." require-expiration-time="true" require-scheme="Bearer" require-signed-tokens="true">
            <openid-config url="https://issuer2.com/.well-known/openid-configuration" />
            <audiences>
              <audience>{tenant02-cliwnt-id}</audience>
            </audiences>
          </validate-jwt>
        </when>
        <otherwise>
          <return-response>
            <set-status code="401" reason="Unauthorized" />
            <set-body>Invalid token issuer.</set-body>
          </return-response>
        </otherwise>
      </choose>

  </inbound>
  <backend>
    <!-- statements to be applied before the request is forwarded to 
         the backend service go here -->
  </backend>
  <outbound>
    <!-- statements to be applied to the response go here -->
  </outbound>
  <on-error>
    <!-- statements to be applied if there is an error condition go here -->
  </on-error>
</policies> 
```

## Useful Links
### Entra Identity platform references
[Entra ID token Claims](https://learn.microsoft.com/en-us/entra/identity-platform/id-token-claims-reference)  
### APIM policy references
[validate-jwt](https://learn.microsoft.com/en-us/azure/api-management/validate-jwt-policy)  
[validate-azure-ad-token](https://learn.microsoft.com/en-us/azure/api-management/validate-azure-ad-token-policy)  
[set-variable](https://learn.microsoft.com/en-us/azure/api-management/set-variable-policy)  
[choose](https://learn.microsoft.com/en-us/azure/api-management/choose-policy)  
