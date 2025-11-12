# Developer Guide

This guide is for developers who want to build and distribute c8store.

## Building for Distribution

### 1. Create OAuth Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable APIs:
   - Firebase Management API
   - Cloud Resource Manager API
4. Create OAuth 2.0 Client ID (Desktop app type)
5. Copy Client ID and Client Secret

### 2. Configure Credentials

You have two options:

#### Option A: Environment Variables (Recommended for CI/CD)

Build with environment variables:

```bash
flutter build macos --dart-define=OAUTH_CLIENT_ID=your_client_id \
                    --dart-define=OAUTH_CLIENT_SECRET=your_client_secret
```

#### Option B: Config File (Recommended for Local Development)

Create `oauth_config.json` in project root:

```json
{
  "clientId": "YOUR_CLIENT_ID.apps.googleusercontent.com",
  "clientSecret": "YOUR_CLIENT_SECRET"
}
```

Then build normally:

```bash
flutter build macos
```

### 3. Distribution

The built app will include the OAuth credentials. End users just need to:

1. Download and install the app
2. Run it
3. Sign in with Google

No additional setup required for end users!

## Development

### Local Development

For local development, create `oauth_config.json` in the project root. This file is gitignored for security.

### Code Structure

```
lib/
├── main.dart                 # Entry point, OAuth config loading
├── models/                   # Data models
├── services/                 # Business logic (OAuth, Firebase, Firestore)
├── providers/                # State management
└── screens/                  # UI screens
```

### Testing

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .
```

## Security Notes

### OAuth Client Secret in Desktop Apps

Desktop applications (unlike web apps) cannot truly hide client secrets because:
- Users can reverse engineer the binary
- No secure server-side component
- Client runs on user's machine

This is a known limitation of OAuth for desktop apps. The risk is acceptable because:

1. **Limited Scope**: OAuth scopes limit what can be done with leaked credentials
2. **User Consent**: Each user must still grant permission
3. **Rate Limiting**: Google applies rate limits per client
4. **Open Source**: Transparency shows we're not doing anything malicious

### Best Practices

- Use specific OAuth scopes (don't request more than needed)
- Monitor usage in Google Cloud Console
- Rotate credentials if compromised
- Consider implementing additional security layers for sensitive operations

## Release Process

1. Update version in `pubspec.yaml`
2. Update RELEASE notes
3. Build for all platforms with OAuth credentials:

```bash
# macOS
flutter build macos --dart-define=OAUTH_CLIENT_ID=xxx --dart-define=OAUTH_CLIENT_SECRET=yyy

# Windows
flutter build windows --dart-define=OAUTH_CLIENT_ID=xxx --dart-define=OAUTH_CLIENT_SECRET=yyy

# Linux
flutter build linux --dart-define=OAUTH_CLIENT_ID=xxx --dart-define=OAUTH_CLIENT_SECRET=yyy
```

4. Package and distribute

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.
