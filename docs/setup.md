# Setup Guide

This guide will walk you through setting up c8store on your machine.

## Prerequisites

- Flutter SDK (3.9.2 or higher)
- A Google account with access to Firebase projects
- Desktop platform (macOS, Windows, or Linux)

## Step 1: Clone and Install

```bash
# Clone the repository
git clone <repository-url>
cd c8store

# Install dependencies
flutter pub get
```

## Step 2: Create Google OAuth Credentials

### 2.1 Access Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Navigate to "APIs & Services" → "Credentials"

### 2.2 Enable Required APIs

Enable the following APIs for your project:

1. **Firebase Management API**
   - Go to "APIs & Services" → "Library"
   - Search for "Firebase Management API"
   - Click "Enable"

2. **Cloud Resource Manager API**
   - Search for "Cloud Resource Manager API"
   - Click "Enable"

### 2.3 Create OAuth 2.0 Client ID

1. Go to "Credentials" → "Create Credentials" → "OAuth client ID"
2. If prompted, configure the OAuth consent screen:
   - User Type: External (or Internal if using Google Workspace)
   - App name: c8store
   - User support email: your email
   - Developer contact: your email
   - Scopes: Add `https://www.googleapis.com/auth/cloud-platform`

3. Create OAuth Client ID:
   - Application type: **Desktop app**
   - Name: c8store (or any name you prefer)

4. Click "Create"
5. **Important**: Copy the Client ID and Client Secret

## Step 3: Configure OAuth Credentials

### 3.1 Create Configuration File

Create a file named `oauth_config.json` in the **project root directory** (same level as pubspec.yaml):

```json
{
  "clientId": "1234567890-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com",
  "clientSecret": "GOCSPX-abcdefghijklmnopqrstuvwxyz"
}
```

Replace the values with your actual Client ID and Client Secret.

### 3.2 Verify File Location

Your project structure should look like this:

```
c8store/
├── oauth_config.json          ← Your config file here
├── pubspec.yaml
├── lib/
├── docs/
└── ...
```

**Security Note**: The `oauth_config.json` file is automatically ignored by git. Never commit this file to version control.

## Step 4: Run the Application

### macOS

```bash
flutter run -d macos
```

### Windows

```bash
flutter run -d windows
```

### Linux

```bash
flutter run -d linux
```

## Step 5: First Login

1. The app will open and show the Welcome screen
2. Click "Sign in with Google"
3. Your default browser will open with Google's OAuth consent screen
4. Sign in with your Google account
5. Grant the requested permissions
6. You'll be redirected back to the app
7. Select a Firebase project from the list

## Troubleshooting

### "OAuth Configuration Required" Screen

If you see this screen, it means the app couldn't find or load your OAuth credentials.

**Solution**:
1. Verify `oauth_config.json` exists in the project root
2. Check the file format is valid JSON
3. Ensure Client ID and Client Secret are correct
4. Restart the application

### Sign-in Fails

**Problem**: Browser opens but sign-in doesn't complete

**Solutions**:
- Check that OAuth consent screen is properly configured
- Verify the redirect URI in Google Cloud Console
- Ensure required APIs are enabled
- Check your internet connection

### No Firebase Projects Shown

**Problem**: Sign-in succeeds but no projects appear

**Solutions**:
- Verify your Google account has access to Firebase projects
- Check Firebase Management API is enabled
- Ensure the OAuth scope includes `cloud-platform`
- Try refreshing by logging out and back in

### Port Already in Use

**Problem**: Error about port 8080 already in use

**Solution**: The OAuth service will automatically try ports 8080-8090. Close any applications using these ports or wait a moment and try again.

## Development Setup

If you're planning to develop or contribute to c8store:

### Code Quality Tools

```bash
# Analyze code for issues
flutter analyze

# Format code
flutter format .

# Run tests
flutter test
```

### Project Structure

```
lib/
├── main.dart                    # Entry point
├── models/                      # Data models
├── services/                    # Business logic
├── providers/                   # State management
└── screens/                     # UI screens
```

## Next Steps

- Read the [User Guide](./user-guide.md) to learn how to use c8store
- Check [PRD documents](./prd/) for feature specifications
- Visit [GitHub Issues](../../issues) to report bugs or request features

## Getting Help

If you encounter issues not covered in this guide:

1. Check existing [GitHub Issues](../../issues)
2. Create a new issue with:
   - Your platform (macOS/Windows/Linux)
   - Flutter version (`flutter --version`)
   - Error messages or screenshots
   - Steps to reproduce
