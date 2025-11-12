# C8Store Documentation

Welcome to the C8Store documentation!

## Table of Contents

- [Getting Started](#getting-started)
- [Installation](#installation)
- [User Guide](#user-guide)
- [Release Notes](#release-notes)
- [Contributing](#contributing)

## Getting Started

C8Store (씨팔스토어) is a convenient tool for managing Firestore databases. This documentation will help you get started with installation, configuration, and usage.

## Installation

For detailed setup instructions, see the [Setup Guide](./setup.md).

### Quick Start

1. Clone the repository and install dependencies:

   ```bash
   git clone https://github.com/your-org/c8store.git
   cd c8store
   flutter pub get
   ```

2. Create Google OAuth credentials (see [Setup Guide](./setup.md))

3. Create `oauth_config.json` in project root:

   ```json
   {
     "clientId": "YOUR_CLIENT_ID.apps.googleusercontent.com",
     "clientSecret": "YOUR_CLIENT_SECRET"
   }
   ```

4. Run the application:

   ```bash
   flutter run -d macos  # for macOS
   flutter run -d linux  # for Linux
   flutter run -d windows  # for Windows
   ```

## User Guide

### Features

- **Multi-Store Support**: Connect and manage multiple Firestore instances
- **Multi-Firebase Support**: Work with multiple Firebase projects simultaneously
- **Table View**: View and edit Firestore data in an intuitive table format
- **Easy Navigation**: Simple and user-friendly interface

### Configuration

#### OAuth Setup

C8Store uses Google OAuth 2.0 for authentication. You need to:

1. Create OAuth credentials in Google Cloud Console
2. Configure the credentials in `oauth_config.json`

See the [Setup Guide](./setup.md) for detailed instructions.

#### Connecting to Firebase Projects

After signing in with Google:

1. The app will automatically list all Firebase projects you have access to
2. Select a project from the list
3. Browse collections and documents in that project

### Usage

#### Managing Collections

- View all collections in the selected Firebase project
- Browse documents within each collection
- (More features coming soon)

#### Settings

- Switch between Firebase projects
- Logout and clear credentials

## Release Notes

All release notes are available in the [RELEASE](./RELEASE) directory.

- [Version 1.0.0](./RELEASE/1.0.0.md) - Initial release

## Contributing

We welcome contributions to C8Store! Please see our issue templates in `.github/ISSUE_TEMPLATE/`:

- [Feature Request](.github/ISSUE_TEMPLATE/FEATURE_REQUEST_TEMPLATE.md)
- [Bug Report](.github/ISSUE_TEMPLATE/BUG_REPORT_TEMPLATE.md)
- [Documentation Request](.github/ISSUE_TEMPLATE/DOCUMENTATION_REQUEST_TEMPLATE.md)
- [Question](.github/ISSUE_TEMPLATE/QUESTION_TEMPLATE.md)

## License

This project is licensed under the Apache-2.0 License. See the [LICENSE](../LICENSE) file for details.
