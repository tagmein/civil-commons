# civil-commons
A public gathering space for internet-enabled minds.

## Google OAuth (Gmail accounts)

To add Gmail accounts via OAuth, set these environment variables:

- `GOOGLE_CLIENT_ID` – from [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services → Credentials
- `GOOGLE_CLIENT_SECRET` – from the same OAuth 2.0 client

Create a Web application client and add this redirect URI:

- `http://localhost:4567/api/auth/google/callback` (for local dev)
