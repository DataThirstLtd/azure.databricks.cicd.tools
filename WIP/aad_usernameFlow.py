import requests
import json
import time
from adal import AuthenticationContext
# acquire the token by calling an example function above


def list_cluster_with_aad_token(refresh_token, access_token):
    # e.g., westus.azuredatabricks.net
    DOMAIN = '<REGION>.azuredatabricks.net' 
    TOKEN = access_token  # obtained above
    BASE_URL = 'https://%s/api/2.0/clusters/list' % (DOMAIN)
    # set the ORG_ID if it is available.
    # otherwise, you must include DB_RESOURCE_ID in the header
    
    ORG_ID = '<org_id>'

    # information required to build the DB_RESOURCE_ID
    SUBSCRIPTION = '<azure sub ID>'
    RESOURCE_GROUP = '<resource group name>'
    WORKSPACE = '<Workspace name>'


    DB_RESOURCE_ID = '/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Databricks/workspaces/%s' % (
            SUBSCRIPTION,
            RESOURCE_GROUP,
            WORKSPACE
        )

    # request header with org_id if org_id is known
    headers_with_org_id = {
        'Authorization' : 'Bearer ' + TOKEN,
        'X-Databricks-Org-Id' : ORG_ID,
    }

    # request header with resource ID if org_id is not available 
    # (e.g., the workspace has not been created yet when you call the REST API)
    headers_with_resource_id = {
        'Authorization' : 'Bearer ' + TOKEN,
        'X-Databricks-Azure-Workspace-Resource-Id' : DB_RESOURCE_ID    
    }

            # call the API with org_id if it is known
    response = requests.get(
        BASE_URL,
        headers=headers_with_org_id
    ).json()

    # OR, call the API with resource_id if org_id is not known
    response = requests.get(
        BASE_URL,
        headers=headers_with_resource_id
    ).json()

    for cluster in response['clusters']:
        print str(cluster)


def passthrough_with_aad_token(refresh_token, access_token):

    DOMAIN = '<REGION>.azuredatabricks.net' 
    CLUSTER_ID = '<CLUSTER ID'
    TOKEN = access_token  # obtained above
    BASE_URL = 'https://%s/api/1.2/contexts/create' % (DOMAIN)
    data = {"language": "python", "clusterId": CLUSTER_ID}
    # set the ORG_ID if it is available.
    # otherwise, you must include DB_RESOURCE_ID in the header
    
    ORG_ID = '<org_id>'

    # information required to build the DB_RESOURCE_ID
    SUBSCRIPTION = '<azure sub ID>'
    RESOURCE_GROUP = '<resource group name>'
    WORKSPACE = '<Workspace name>'

    DB_RESOURCE_ID = '/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Databricks/workspaces/%s' % (
            SUBSCRIPTION,
            RESOURCE_GROUP,
            WORKSPACE
        )

    # request header with org_id if org_id is known
    headers_with_org_id = {
        'Authorization' : 'Bearer ' + TOKEN,
        'X-Databricks-Org-Id' : ORG_ID,
    }

    # request header with resource ID if org_id is not available 
    # (e.g., the workspace has not been created yet when you call the REST API)
    headers_with_resource_id = {
        'Authorization' : 'Bearer ' + TOKEN,
        'X-Databricks-Azure-Workspace-Resource-Id' : DB_RESOURCE_ID    
    }

    print BASE_URL
    exec_create = requests.post(BASE_URL, data=data, headers=headers_with_org_id)
    print exec_create.text
    exec_ctx_id = json.loads(exec_create.text)['id']

    CMD_URL = 'https://%s/api/1.2/commands/execute' % (DOMAIN)
    cmd_data = {
        'language': 'python',
        'contextId': exec_ctx_id,
        'clusterId': CLUSTER_ID,
        'command': 'df = spark.read.csv("adl://<ADLSNAME>.azuredatalakestore.net/anna/australiacentral.csv").collect()'
    }
    cmd_run = requests.post(CMD_URL, data=cmd_data, headers=headers_with_org_id)
    print(cmd_run)
    print(cmd_run.text)
    cmd_id = json.loads(cmd_run.text)['id']
    RESP_URL = 'https://%s/api/1.2/commands/status' % (DOMAIN)
    while True:
        r = requests.get(RESP_URL + '?clusterId=%s&contextId=%s&commandId=%s' % (CLUSTER_ID, exec_ctx_id, cmd_id),
                headers=headers_with_org_id)
        print(r)
        print(r.text)
        time.sleep(2)



##AAD token
authority_host_url = "https://login.microsoftonline.com/"
    # the Application ID of  AzureDatabricks 
databricks_resource_id = "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d"

# Required user input
user_parameters = {
     "tenant" : "<tenant>",
     "clientId" : "<your app ID>",
     "username" : "<username>",
     "password" : "<password>"
}



# configure AuthenticationContext (reference link)
# authority URL and tenant ID are used
authority_url = authority_host_url + user_parameters['tenant']
context = AuthenticationContext(authority_url)

# API call to get the token (function link)
token_response = context.acquire_token_with_username_password(
    databricks_resource_id, 
    user_parameters['username'],
    user_parameters['password'], 
    user_parameters['clientId'])

# both refresh token and access token will be returned in the token_response
refresh_token = token_response['refreshToken']
access_token = token_response['accessToken']
print access_token
#list_cluster_with_aad_token(refresh_token, access_token)
passthrough_with_aad_token(refresh_token, access_token)
