# Set Up Google OIDC

1. Access Google Cloud Platform
2. Create a new project
3. Go to APIs & Services -> OAuth consent screen
   - App name: Excalidraw
   - User support email: <EMAIL_ADDRESS>
   - User Type: Internal
   - Contact Information: <EMAIL_ADDRESS>
4. Go to APIs & Services -> Credentials
5. Create OAuth client ID
   - Application type: Web application
   - Name: Excalidraw
   - Authorized redirect URIs
     - Redirect URI: `https://<YOUR_FQDN>/oauth2/callback`
6. Save the Client ID and Client Secret

```bash
# VM

# Move to repository
cd ExcalidrawCollaboration

# Generate the OAuth2 Proxy cookie secret
openssl rand -base64 32 | tr -- '+/' '-_'

# Edit .env file
vi .env
```

```env
# Required
OAUTH2_PROXY_PROVIDER=google
OAUTH2_PROXY_CLIENT_ID=<GOOGLE_CLIENT_ID>
OAUTH2_PROXY_CLIENT_SECRET=<GOOGLE_CLIENT_SECRET>
OAUTH2_PROXY_OIDC_ISSUER_URL=https://accounts.google.com
OAUTH2_PROXY_REDIRECT_URL=https://<YOUR_FQDN>/oauth2/callback
OAUTH2_PROXY_SCOPE=openid email profile
OAUTH2_PROXY_COOKIE_SECRET=<GENERATED_COOKIE_SECRET>
```
