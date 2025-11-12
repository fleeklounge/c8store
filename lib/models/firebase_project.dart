/// Firebase project model representing a Firebase/GCP project
class FirebaseProject {
  /// Unique project identifier
  final String projectId;

  /// Human-readable project display name
  final String displayName;

  /// GCP project number
  final String projectNumber;

  /// GCP resource location (e.g., us-central1)
  final String? location;

  /// Timestamp when this project was connected to the app
  final DateTime connectedAt;

  /// User-defined custom label for project organization
  final String? customLabel;

  FirebaseProject({
    required this.projectId,
    required this.displayName,
    required this.projectNumber,
    this.location,
    required this.connectedAt,
    this.customLabel,
  }) {
    if (projectId.isEmpty) {
      throw ArgumentError('projectId cannot be empty');
    }
    if (displayName.isEmpty) {
      throw ArgumentError('displayName cannot be empty');
    }
    if (projectNumber.isEmpty) {
      throw ArgumentError('projectNumber cannot be empty');
    }
  }

  /// Create FirebaseProject from JSON map
  factory FirebaseProject.fromJson(Map<String, dynamic> json) {
    return FirebaseProject(
      projectId: json['projectId'] as String,
      displayName: json['displayName'] as String,
      projectNumber: json['projectNumber'] as String,
      location: json['location'] as String?,
      connectedAt: DateTime.parse(json['connectedAt'] as String),
      customLabel: json['customLabel'] as String?,
    );
  }

  /// Convert FirebaseProject to JSON map
  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'displayName': displayName,
      'projectNumber': projectNumber,
      'location': location,
      'connectedAt': connectedAt.toIso8601String(),
      'customLabel': customLabel,
    };
  }

  /// Create a copy of this project with optional field updates
  FirebaseProject copyWith({
    String? projectId,
    String? displayName,
    String? projectNumber,
    String? location,
    DateTime? connectedAt,
    String? customLabel,
  }) {
    return FirebaseProject(
      projectId: projectId ?? this.projectId,
      displayName: displayName ?? this.displayName,
      projectNumber: projectNumber ?? this.projectNumber,
      location: location ?? this.location,
      connectedAt: connectedAt ?? this.connectedAt,
      customLabel: customLabel ?? this.customLabel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FirebaseProject &&
        other.projectId == projectId &&
        other.displayName == displayName &&
        other.projectNumber == projectNumber &&
        other.location == location &&
        other.connectedAt == connectedAt &&
        other.customLabel == customLabel;
  }

  @override
  int get hashCode {
    return Object.hash(
      projectId,
      displayName,
      projectNumber,
      location,
      connectedAt,
      customLabel,
    );
  }

  @override
  String toString() {
    return 'FirebaseProject(projectId: $projectId, displayName: $displayName, '
        'projectNumber: $projectNumber, location: $location, '
        'connectedAt: $connectedAt, customLabel: $customLabel)';
  }
}
