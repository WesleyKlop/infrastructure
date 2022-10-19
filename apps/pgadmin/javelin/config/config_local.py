AUTHENTICATION_SOURCES = ['oauth2', 'internal']


OAUTH2_CONFIG = [
    {
        # The name of the of the oauth provider, ex: github, google
        'OAUTH2_NAME': 'Keycloak',
        # The display name, ex: Google
        'OAUTH2_DISPLAY_NAME': 'Keycloak',
        # Oauth client id
        'OAUTH2_CLIENT_ID': 'pgadmin',
        # Oauth secret
        'OAUTH2_CLIENT_SECRET': os.environ['APP_OAUTH_SECRET'],
        # URL to generate a token,
        # Ex: https://github.com/login/oauth/access_token
        'OAUTH2_TOKEN_URL': 'https://keycloak.wesl.io/realms/master/protocol/openid-connect/token',
        # URL is used for authentication,
        # Ex: https://github.com/login/oauth/authorize
        'OAUTH2_AUTHORIZATION_URL': 'https://keycloak.wesl.io/realms/master/protocol/openid-connect/auth',
        # Oauth base url, ex: https://api.github.com/
        'OAUTH2_API_BASE_URL': 'https://keycloak.wesl.io/realms/master/protocol/openid-connect/',
        # Name of the Endpoint, ex: user
        'OAUTH2_USERINFO_ENDPOINT': 'userinfo',
        # Oauth scope, ex: 'openid email profile'
        # Note that an 'email' claim is required in the resulting profile
        'OAUTH2_SCOPE': 'openid email profile',
        # Font-awesome icon, ex: fa-github
        'OAUTH2_ICON': None,
        # UI button colour, ex: #0000ff
        'OAUTH2_BUTTON_COLOR': None,
    }
]

# After Oauth authentication, user will be added into the SQLite database
# automatically, if set to True.
# Set it to False, if user should not be added automatically,
# in this case Admin has to add the user manually in the SQLite database.

OAUTH2_AUTO_CREATE_USER = True