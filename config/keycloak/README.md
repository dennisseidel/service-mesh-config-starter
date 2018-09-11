# Keycloak Setup
## Documentation
* [Helm Chart](https://github.com/helm/charts/tree/master/stable/keycloak)
* [Keycloak](https://www.keycloak.org/docs/latest/server_admin/index.html)

## Features
### As a user I can Signs up
(you might want to import a existing configuration: [Docs](https://www.keycloak.org/docs/latest/server_admin/index.html#admin-console-export-import))
- Configure Realm / Tenant: e.g. `d10l`, `google`
- Configure Singup Possibility: `Realm Setting` -> `Login` -> Allow `User Registration` (User Registration field can be updated [Docs](https://www.keycloak.org/docs/latest/server_admin/index.html#_user-registration))

### Register an Client 
You can always use the admin account do it in the admin ui. For a more automatic option one can use the [REST Admin API] (https://www.keycloak.org/docs-api/4.0/rest-api/index.html) either using the [admin credentials](https://stackoverflow.com/questions/46470477/how-to-get-keycloak-users-via-rest-without-admin-account) or better through a seperate client using the client credential grant:

- create a client in the realm e.g. `developer-portal` and under `Settings` set `Access Type` to `confidential`, then activate `Service Account Enable`, add a redirect uri (we will not used it - therefore any uri will do) and klick on save: Documentation on [Service Accounts](https://www.keycloak.org/docs/latest/server_admin/index.html#_service_accounts] and [Client Credential](https://www.keycloak.org/docs/latest/server_admin/index.html#_client-credentials).
- Now the section `Credentials` appears where you will find the *client secret*. This and the *client id* from the *settings section* are required to request an access token.
- Base64 encode the credentials `developer-portal:ec36f50c-b72f-4c40-8d39-63f2f66444c6` -> `ZGV2ZWxvcGVyLXBvcnRhbDplYzM2ZjUwYy1iNzJmLTRjNDAtOGQzOS02M2YyZjY2NDQ0YzY=`
- Reqest a token:
```bash 
curl -X POST 'http://accounts.d10l.de/auth/realms/d10l/protocol/openid-connect/token' \
 -H "Content-Type: application/x-www-form-urlencoded" \
 -H "Authorization: Basic ZGV2ZWxvcGVyLXBvcnRhbDplYzM2ZjUwYy1iNzJmLTRjNDAtOGQzOS02M2YyZjY2NDQ0YzY=" \
 -d 'grant_type=client_credentials' \
| jq -r '.access_token'
```
- This token only includes the default claims and roles. To add addtional roles go to the *Service Account Roles* section and add them.  Make shure that they are also included in the *Scope* section where the scopes the client is allowed to request are managed. 

### Manage Keycloak (e.g. add a new client)
You can use this token to make requests to the admin api e.g. creating a client(https://www.keycloak.org/docs-api/4.0/rest-api/index.html#_clients_resource)

```bash
curl -X GET 'http://accounts.d10l.de/auth/admin/realms/d10l/clients' \
-H "Accept: application/json" \
-H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI0SHJMTEhrTDNlZTVtaWtFWXo1eVFqR0hZVmxXZUJMcGpBS1pVcG5WLUtvIn0.eyJqdGkiOiI0MWU4NDIxNy1hYWEyLTQ2MzYtODc1Yy1mYzA3Nzc2MGI5YjciLCJleHAiOjE1MzY2NzgyMDcsIm5iZiI6MCwiaWF0IjoxNTM2Njc3OTA3LCJpc3MiOiJodHRwOi8vYWNjb3VudHMuZDEwbC5kZS9hdXRoL3JlYWxtcy9kMTBsIiwiYXVkIjoiZGV2ZWxvcGVyLXBvcnRhbCIsInN1YiI6Ijc5ZDIyNzFiLTdiMzQtNGQxOS1iMjM5LWVkOTA0NzZkYzhiYiIsInR5cCI6IkJlYXJlciIsImF6cCI6ImRldmVsb3Blci1wb3J0YWwiLCJhdXRoX3RpbWUiOjAsInNlc3Npb25fc3RhdGUiOiIyZWU2YjU2ZC1lMjcxLTRiYzQtYjMzOC02MDgxOGQ4MTllMjkiLCJhY3IiOiIxIiwiYWxsb3dlZC1vcmlnaW5zIjpbXSwicmVzb3VyY2VfYWNjZXNzIjp7InJlYWxtLW1hbmFnZW1lbnQiOnsicm9sZXMiOlsiY3JlYXRlLWNsaWVudCIsIm1hbmFnZS1jbGllbnRzIiwicXVlcnktY2xpZW50cyJdfX0sInNjb3BlIjoicHJvZmlsZSBlbWFpbCIsImNsaWVudEhvc3QiOiIxNzIuMTcuMC4xIiwiY2xpZW50SWQiOiJkZXZlbG9wZXItcG9ydGFsIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJzZXJ2aWNlLWFjY291bnQtZGV2ZWxvcGVyLXBvcnRhbCIsImNsaWVudEFkZHJlc3MiOiIxNzIuMTcuMC4xIiwiZW1haWwiOiJzZXJ2aWNlLWFjY291bnQtZGV2ZWxvcGVyLXBvcnRhbEBwbGFjZWhvbGRlci5vcmcifQ.f3CWEU_C4jSxZNcY2oFFGEIx36cxgT0Kpjn9kL9iiNSf1tFUf-qyPts04X__JaehdXpivB03jVAtDrSdfkMq21Js5keKt3N_Pqs3HsTIndQLxg-CwL9ODW13zK81GEvGZk3GihrYv-pu9D0IaVnth3hBnukLjeUnKbk7EXKPOy9BQMNaVGd0u1Oag2ipvpfS4PJgdIYpfsVoifJw-6A_YZopkdBNw_m67MgVXwrdG4Aotf27xiRk2_POADL3lRfqnrGkO1Muw_jb_8fjaPA98BMcbxDHeb-BI8vAc40n5MyT5oQe3xihDnaJ-I8_JtyZbatUpSAjtlkfyYCCuOvsNw" | jq .
```

# Endpoints & Links
* Infos: http://accounts.d10l.de/auth/realms/d10l/
* Account (Self-) Management: "http://accounts.d10l.de/auth/realms/d10l/account"