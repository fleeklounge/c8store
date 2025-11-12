# Detailed OAuth Setup Guide

## Step-by-Step Instructions

### Part 1: Create Google Cloud Project

1. Go to https://console.cloud.google.com/
2. Click "Select a project" → "New Project"
3. Project name: `c8store` (or any name)
4. Click "Create"

### Part 2: Configure OAuth Consent Screen (REQUIRED!)

1. Go to **APIs & Services** → **OAuth consent screen**

2. **User Type**:
   - Select **External**
   - Click "Create"

3. **App Information**:
   - App name: `c8store`
   - User support email: (select your email)
   - App logo: (optional)
   - Application home page: (optional)
   - Developer contact information: (your email)
   - Click "SAVE AND CONTINUE"

4. **Scopes**:
   - Click "ADD OR REMOVE SCOPES"
   - In the filter box, search for: `cloud-platform`
   - Check the box for: `https://www.googleapis.com/auth/cloud-platform`
   - Description: "See, edit, configure, and delete your Google Cloud data"
   - Click "UPDATE"
   - Click "SAVE AND CONTINUE"

5. **Test users** (Important for External apps):
   - Click "ADD USERS"
   - Enter your Google account email(s) that you'll use to test
   - Click "Add"
   - Click "SAVE AND CONTINUE"

6. **Summary**:
   - Review and click "BACK TO DASHBOARD"

### Part 3: Enable Required APIs

1. Go to **APIs & Services** → **Library**

2. Search and enable each:
   - **Firebase Management API**
     - Search "Firebase Management API"
     - Click on it
     - Click "ENABLE"

   - **Cloud Resource Manager API**
     - Search "Cloud Resource Manager API"
     - Click on it
     - Click "ENABLE"

### Part 4: Create OAuth Client ID

1. Go to **APIs & Services** → **Credentials**

2. Click "**+ CREATE CREDENTIALS**" → "OAuth client ID"

3. **Application type**:
   - Select **Desktop app** (NOT Web application!)

4. **Name**: `c8store` (or any name)

5. Click "**CREATE**"

6. **Important**: Copy both values:
   - Client ID (looks like: `123456789-xxxxx.apps.googleusercontent.com`)
   - Client Secret (looks like: `GOCSPX-xxxxx`)

### Part 5: Configure c8store

1. Open `oauth_config.json` in the project root

2. Replace with your actual values:

```json
{
  "clientId": "PASTE_YOUR_CLIENT_ID_HERE.apps.googleusercontent.com",
  "clientSecret": "PASTE_YOUR_CLIENT_SECRET_HERE"
}
```

Example (with fake values):
```json
{
  "clientId": "123456789012-abcdefghijklmnop.apps.googleusercontent.com",
  "clientSecret": "GOCSPX-aBcDeFgHiJkLmNoPqRsTuVwXyZ"
}
```

3. Save the file

4. Restart the app:
```bash
flutter run -d macos
```

## Common Issues

### "invalid_client" Error
- OAuth client not found
- **Solution**: Double-check Client ID is correct in oauth_config.json

### 400 Error "malformed request"
- OAuth consent screen not configured
- **Solution**: Complete Part 2 above, especially adding scopes

### "access_denied" Error
- You're not added as a test user
- **Solution**: Add your email in OAuth consent screen → Test users

### "redirect_uri_mismatch" Error
- This shouldn't happen with Desktop apps
- **Solution**: Make sure Application type is "Desktop app", not "Web application"

### No Firebase projects showing after login
- APIs not enabled
- **Solution**: Enable Firebase Management API and Cloud Resource Manager API (Part 3)

## Testing

1. Run the app
2. Click "Sign in with Google"
3. Browser opens with Google sign-in
4. Sign in with the email you added as a test user
5. Grant permissions (click "Allow")
6. Browser shows success message
7. App should show your Firebase projects

## Publishing the App (Later)

When ready to publish:
1. Go back to OAuth consent screen
2. Click "PUBLISH APP"
3. This removes the test user restriction
4. Anyone can use your app
