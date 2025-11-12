# PRD: Google OAuth-based Firestore Connection

## Overview

c8store is a Flutter desktop application that serves as a Firestore management tool for developers. This PRD defines the authentication and connection mechanism that allows developers to seamlessly connect to multiple Firestore projects using Google OAuth, eliminating the need for manual Service Account file management.

## Problem Statement

Current Firestore management tools require developers to:

- Manually download Service Account JSON files
- Upload and manage these sensitive files
- Repeat this process for every Firebase project and environment
- Deal with security risks of Service Account file storage

This creates friction in the developer workflow, especially when managing multiple Firebase projects across different environments (development, staging, production) or regions (country-specific Firestore instances).

## Goals

### Primary Goals

- Enable developers to connect to any Firestore project with just Google OAuth login
- Provide seamless switching between multiple Firebase projects
- Eliminate manual Service Account file management
- Support multiple environments (dev, staging, prod) and regional deployments

### Secondary Goals

- Maintain high security standards
- Provide fast and responsive UI
- Support offline credential caching
- Minimize setup time for new projects

## User Stories

### Story 1: First-time User Connection

As a developer using c8store for the first time,
I want to log in with my Google account and see all my Firebase projects,
So that I can quickly start managing my Firestore data without complex setup.

**Acceptance Criteria:**

- User clicks "Sign in with Google"
- OAuth flow opens in system browser
- After authorization, user sees a list of all accessible Firebase projects
- User selects a project and immediately sees Firestore collections

### Story 2: Multi-project Developer

As a developer managing multiple Firebase projects,
I want to easily switch between different projects,
So that I can manage data across dev/staging/prod environments efficiently.

**Acceptance Criteria:**

- User can view all connected projects in a sidebar
- Clicking a project switches the active connection
- Previously selected projects are remembered
- Connection state persists across app restarts

### Story 3: Regional Deployment Manager

As a developer with country-specific Firebase projects,
I want to manage multiple regional Firestore instances,
So that I can handle geo-distributed data efficiently.

**Acceptance Criteria:**

- User can connect to multiple Firebase projects (e.g., US, EU, APAC)
- Projects are clearly labeled with custom names/tags
- Can switch between regional projects seamlessly

## Technical Requirements

### Authentication Flow

#### Phase 1: Google OAuth Authentication

1. **OAuth Initialization**
   - Use `googleapis_auth` package for OAuth flow
   - Request scope: `https://www.googleapis.com/auth/cloud-platform`
   - Use Desktop App OAuth client type
   - Implement local server callback (localhost redirect)

2. **Token Management**
   - Obtain OAuth 2.0 access token and refresh token
   - Store tokens securely using `flutter_secure_storage`
   - Implement automatic token refresh mechanism
   - Handle token expiration gracefully

#### Phase 2: Firebase Project Discovery

1. **Project Listing**
   - Call Firebase Management API: `projects.list`
   - Endpoint: `https://firebase.googleapis.com/v1beta1/projects`
   - Parse response to extract project metadata

2. **Project Information**
   - Project ID
   - Project display name
   - Project number
   - GCP resource location

#### Phase 3: Firestore Access

1. **REST API Implementation**
   - Use Firestore REST API instead of Admin SDK
   - Base URL: `https://firestore.googleapis.com/v1/`
   - Pass OAuth token in Authorization header: `Bearer {access_token}`

2. **Core Operations**
   - List collections
   - List documents in a collection
   - Get document details
   - Create/Update/Delete documents
   - Query documents with filters

### Data Models

#### Project Model

```dart
class FirebaseProject {
  final String projectId;
  final String displayName;
  final String projectNumber;
  final String? location;
  final DateTime connectedAt;
  final String? customLabel; // User-defined label
}
```

#### Connection State

```dart
class ConnectionState {
  final String? activeProjectId;
  final List<FirebaseProject> projects;
  final OAuthCredentials credentials;
  final DateTime lastSync;
}
```

#### OAuth Credentials

```dart
class OAuthCredentials {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final List<String> scopes;
}
```

### Security Requirements

1. **Token Storage**
   - Use `flutter_secure_storage` for token persistence
   - Encrypt tokens at rest
   - Clear tokens on logout

2. **Network Security**
   - Use HTTPS for all API calls
   - Implement certificate pinning for critical endpoints
   - Validate SSL certificates

3. **Error Handling**
   - Handle OAuth errors gracefully
   - Provide clear error messages
   - Implement retry mechanism with exponential backoff

### API Endpoints

#### Firebase Management API

- **List Projects**: `GET https://firebase.googleapis.com/v1beta1/projects`
- **Get Project**: `GET https://firebase.googleapis.com/v1beta1/projects/{projectId}`

#### Firestore REST API

- **List Collections**: `GET https://firestore.googleapis.com/v1/projects/{projectId}/databases/(default)/documents`
- **List Documents**: `GET https://firestore.googleapis.com/v1/projects/{projectId}/databases/(default)/documents/{collectionId}`
- **Get Document**: `GET https://firestore.googleapis.com/v1/projects/{projectId}/databases/(default)/documents/{documentPath}`
- **Create Document**: `POST https://firestore.googleapis.com/v1/projects/{projectId}/databases/(default)/documents/{collectionId}`
- **Update Document**: `PATCH https://firestore.googleapis.com/v1/projects/{projectId}/databases/(default)/documents/{documentPath}`
- **Delete Document**: `DELETE https://firestore.googleapis.com/v1/projects/{projectId}/databases/(default)/documents/{documentPath}`

## User Interface Design

### Main Screens

#### 1. Welcome Screen (First Launch)

- App logo and branding
- "Sign in with Google" button (prominent)
- Brief description of app features
- Link to documentation

#### 2. Project Selection Screen

- List of accessible Firebase projects
- Search/filter functionality
- Project cards showing:
  - Project name
  - Project ID
  - Last accessed time
  - Custom label (if set)
- "Add Custom Label" option for each project

#### 3. Main Application Screen

- **Sidebar (Left)**
  - User profile section (avatar, email, logout)
  - List of connected projects
  - Currently active project highlighted
  - Quick switch dropdown

- **Main Content Area**
  - Breadcrumb navigation
  - Collection list
  - Document viewer/editor
  - Query builder

### User Flows

#### First-Time User Flow

```
Launch App
  ↓
Welcome Screen
  ↓
Click "Sign in with Google"
  ↓
Browser opens → Google OAuth consent screen
  ↓
User authorizes app
  ↓
Browser redirects back to app
  ↓
Project Selection Screen (shows all accessible projects)
  ↓
User selects a project
  ↓
Main Application Screen (shows collections)
```

#### Returning User Flow

```
Launch App
  ↓
Auto-login with stored credentials
  ↓
Main Application Screen (last active project)
  ↓
User can switch projects via sidebar
```

#### Project Switching Flow

```
User in Main Application Screen
  ↓
Clicks different project in sidebar
  ↓
App loads new project's collections
  ↓
Main content area updates
```

## Implementation Phases

### Phase 1: OAuth Authentication (Week 1)

- Implement Google OAuth flow
- Set up local server for redirect handling
- Implement token storage with `flutter_secure_storage`
- Create OAuth credential management service
- Handle token refresh logic

**Deliverables:**

- OAuth service implementation
- Secure token storage
- Basic authentication UI

### Phase 2: Firebase Project Discovery (Week 2)

- Integrate Firebase Management API
- Implement project listing functionality
- Create project data models
- Build project selection UI
- Implement project switching logic

**Deliverables:**

- Firebase Management API client
- Project selection screen
- Project switching mechanism

### Phase 3: Firestore REST API Integration (Week 3-4)

- Implement Firestore REST API client
- Create collection listing functionality
- Build document CRUD operations
- Implement query functionality
- Add error handling and retry logic

**Deliverables:**

- Firestore REST API client
- Collection and document UI
- CRUD operations
- Query builder

### Phase 4: Enhanced Features (Week 5-6)

- Add custom project labels
- Implement search and filter
- Add offline caching
- Performance optimization
- Comprehensive testing

**Deliverables:**

- Enhanced project management
- Optimized performance
- Test coverage

## Success Criteria

### Functional Criteria

- ✅ User can sign in with Google account in under 30 seconds
- ✅ All accessible Firebase projects are displayed after authentication
- ✅ User can switch between projects in under 2 seconds
- ✅ Collections load within 3 seconds after project selection
- ✅ CRUD operations complete successfully 99.9% of the time
- ✅ Credentials persist across app restarts

### Performance Criteria

- ✅ OAuth flow completes in under 10 seconds
- ✅ Project list loads in under 5 seconds
- ✅ Collection list loads in under 3 seconds
- ✅ Document operations complete in under 2 seconds
- ✅ App startup time under 2 seconds with cached credentials

### User Experience Criteria

- ✅ Zero manual file uploads required
- ✅ Clear error messages for all failure scenarios
- ✅ Intuitive project switching mechanism
- ✅ Professional and responsive UI
- ✅ Accessible keyboard shortcuts

## Technical Constraints

### Platform Support

- **Primary**: macOS, Windows, Linux (Desktop only)
- **Not Supported**: iOS, Android, Web (for initial release)

### Dependencies

- Flutter SDK: ^3.9.2
- `googleapis_auth`: For OAuth implementation
- `flutter_secure_storage`: For credential storage
- `http`: For REST API calls
- `provider` or `riverpod`: For state management

### Firebase/GCP Requirements

- User must have access to Firebase projects via their Google account
- Firebase Management API must be enabled (auto-enabled for most projects)
- Firestore must be initialized in the target projects

## Risk Assessment

### Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| OAuth token expiration during operations | Medium | Medium | Implement automatic token refresh with retry logic |
| Firebase Management API rate limiting | Low | Medium | Implement request throttling and caching |
| REST API vs Admin SDK feature gaps | Medium | High | Document limitations and plan for future enhancements |
| Cross-platform OAuth redirect issues | Medium | High | Test thoroughly on all desktop platforms |

### User Experience Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Users without GCP project access | Low | Low | Provide clear error messages and documentation |
| Confusion about project selection | Medium | Medium | Implement search and custom labels |
| Slow project listing for users with many projects | Medium | Medium | Implement pagination and search |

## Future Enhancements

### Post-MVP Features

1. **Advanced Querying**
   - Complex query builder UI
   - Query history and saved queries
   - Query performance analytics

2. **Data Management**
   - Bulk import/export (JSON, CSV)
   - Data migration tools
   - Backup and restore functionality

3. **Collaboration**
   - Share queries with team members
   - Project bookmarking
   - Activity logs

4. **Service Account Support**
   - Optional Service Account upload for advanced users
   - Hybrid authentication mode

5. **Additional Firebase Services**
   - Firebase Authentication user management
   - Cloud Storage browser
   - Realtime Database support

## Appendix

### Research References

- Firebase Management API Documentation: <https://firebase.google.com/docs/projects/api/reference/rest>
- Firestore REST API Documentation: <https://firebase.google.com/docs/firestore/use-rest-api>
- OAuth 2.0 for Desktop Apps: <https://developers.google.com/identity/protocols/oauth2/native-app>
- googleapis_auth Package: <https://pub.dev/packages/googleapis_auth>

### Competitive Analysis

- **Firefoo**: Uses Google OAuth + REST API (similar approach)
- **FirePilot**: Service Account file upload
- **Refi App**: Service Account file upload (open source)

### Glossary

- **ADC**: Application Default Credentials
- **OAuth**: Open Authorization protocol
- **REST API**: Representational State Transfer Application Programming Interface
- **Service Account**: GCP/Firebase machine account for server-to-server authentication
- **Scope**: Permission level for OAuth access tokens
