# Set Up Google OIDC

1. Access the [Google Cloud console](https://console.cloud.google.com/) and create or select a project
2. Go to Google Auth Platform -> Overview and select Get started if prompted
3. Go to Google Auth Platform -> Branding and configure the application
   - App name: Excalidraw
   - User support email: <EMAIL_ADDRESS>
   - Contact Information: <EMAIL_ADDRESS>
4. Go to Google Auth Platform -> Audience
   - User type: Internal when the project belongs to a Google Cloud Organization; otherwise External
   - Add test users when using External in testing mode
5. Go to Google Auth Platform -> Clients -> Create client
   - Application type: Web application
   - Name: Excalidraw
   - Authorized redirect URIs
     - Redirect URI: `https://<YOUR_FQDN>/oauth2/callback`
6. Create the client, then copy the Client ID and Client Secret immediately and store them securely

With the current `OAUTH2_PROXY_EMAIL_DOMAINS=*` setting in `docker-compose.yaml`, a published External app permits any Google account to authenticate. Use Internal, keep the app in testing mode with explicit test users, or change this setting to restrict the allowed email domains when access must be limited.

Add the following values to `.env` during initial setup. For an existing server, follow the **Update Configuration** section in the main README.

```env
# Required
OAUTH2_PROXY_PROVIDER=google
OAUTH2_PROXY_CLIENT_ID=<GOOGLE_CLIENT_ID>
OAUTH2_PROXY_CLIENT_SECRET=<GOOGLE_CLIENT_SECRET>
OAUTH2_PROXY_OIDC_ISSUER_URL=https://accounts.google.com
OAUTH2_PROXY_SCOPE=openid email profile
OAUTH2_PROXY_COOKIE_SECRET=<GENERATED_COOKIE_SECRET>
```
