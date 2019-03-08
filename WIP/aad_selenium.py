from adal import AuthenticationContext
from selenium import webdriver
import time
from urlparse import urlparse, parse_qs
import requests
from adal import AuthenticationContext

authority_host_url = "https://login.microsoftonline.com/"
databricks_resource_id = "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d"

# Required user input
user_parameters = {
     "tenant" : "75e26db8-ef63-42c8-ac89-fbeea21dfe71",
     "clientId" : "35d84174-03db-448e-a4e8-45aa7c8b96c6",
     "redirect_uri" : "http://localhost" #or your redirect uri
}

TEMPLATE_AUTHZ_URL = ('https://login.windows.net/{}/oauth2/authorize?'+
                  'response_type=code&client_id={}&redirect_uri={}&'+
                  'state={}&resource={}')
# the auth_state can be a random number or can encoded some info about the user
# it is used for preventing cross-site request forgery attacks [MS_doc]
auth_state = 12345
# build the URL to request the authorization code
authorization_url = TEMPLATE_AUTHZ_URL.format(
            user_parameters['tenant'],
            user_parameters['clientId'],
            user_parameters['redirect_uri'],
            auth_state,
            databricks_resource_id)

def list_cluster_with_aad_token(refresh_token, access_token):
    # e.g., westus.azuredatabricks.net
    DOMAIN = 'westeurope.azuredatabricks.net' 
    TOKEN = access_token  # obtained above
    BASE_URL = 'https://%s/api/2.0/clusters/list' % (DOMAIN)
    # set the ORG_ID if it is available.
    # otherwise, you must include DB_RESOURCE_ID in the header
    ORG_ID = '2930652350087280'

    # information required to build the DB_RESOURCE_ID
    SUBSCRIPTION = 'b146ae31-d42f-4c88-889b-318f2cc23f98'
    RESOURCE_GROUP = 'dataThirstDatabricks-RG'
    WORKSPACE = 'dataThirstDatabricks'

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



def get_authorization_code():
    # open a browser, here assume we use Chrome
    dr = webdriver.Chrome(executable_path='<path>')
    # load the user login page
    dr.get(authorization_url)
    # wait until the user login or kill the process
    code_received = False
    code = ''
    while(not code_received):
        cur_url = dr.current_url
        if cur_url.startswith(user_parameters['redirect_uri']):
            parsed = urlparse(cur_url)
            query = parse_qs(parsed.query)
            code = query['code'][0]
            state = query['state'][0]
            # throw exception if the state does not match
            if state != str(auth_state):
                raise ValueError('state does not match')
            code_received = True 
            dr.close()

    if not code_received:
        print 'Error in requesting authorization code'
        dr.close()
    # authorization code is returned. If not successful, then an empty code is returned
    return code 


def get_refresh_and_access_token():   
    # configure AuthenticationContext (reference link)
    # authority URL and tenant ID are used
    authority_url = authority_host_url + user_parameters['tenant']
    context = AuthenticationContext(authority_url)

    # Obtain the authorization code in by a HTTP request in the browser then copy it here
    # Or, call the function above to get the authorization code
    authz_code = get_authorization_code()

    # API call to get the token (function link), the response is a key-value dict
    token_response = context.acquire_token_with_authorization_code(
        authz_code,
        user_parameters['redirect_uri'],
        databricks_resource_id, 
        user_parameters['clientId'])

    # you can print all the fields in the token_response
    for key in token_response.keys():
        print str(key) + ': ' + str(token_response[key])

    # the tokens can be returned as a pair (or you can return the full token_response)
    refresh_token = token_response['refreshToken']
    access_token = token_response['accessToken']
    return refresh_token, access_token

refresh_token, access_token = get_refresh_and_access_token()
list_cluster_with_aad_token(refresh_token, access_token)
