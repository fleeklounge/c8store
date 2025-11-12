/// OAuth 2.0 credentials for Firebase/GCP API access
class OAuthCredentials {
  /// OAuth 2.0 access token for API requests
  final String accessToken;

  /// OAuth 2.0 refresh token for obtaining new access tokens
  final String refreshToken;

  /// Expiration timestamp for the access token
  final DateTime expiresAt;

  /// List of OAuth scopes granted to this credential
  final List<String> scopes;

  OAuthCredentials({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.scopes,
  }) {
    if (accessToken.isEmpty) {
      throw ArgumentError('accessToken cannot be empty');
    }
    if (refreshToken.isEmpty) {
      throw ArgumentError('refreshToken cannot be empty');
    }
    if (scopes.isEmpty) {
      throw ArgumentError('scopes cannot be empty');
    }
  }

  /// Check if the access token is currently expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if the access token will expire within the given duration
  bool willExpireIn(Duration duration) {
    return DateTime.now().add(duration).isAfter(expiresAt);
  }

  /// Get time remaining until token expiration
  Duration get timeUntilExpiration {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) {
      return Duration.zero;
    }
    return expiresAt.difference(now);
  }

  /// Create OAuthCredentials from JSON map
  factory OAuthCredentials.fromJson(Map<String, dynamic> json) {
    return OAuthCredentials(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      scopes: (json['scopes'] as List<dynamic>).cast<String>(),
    );
  }

  /// Convert OAuthCredentials to JSON map
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      'scopes': scopes,
    };
  }

  /// Create a copy of this credential with optional field updates
  OAuthCredentials copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    List<String>? scopes,
  }) {
    return OAuthCredentials(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      scopes: scopes ?? this.scopes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OAuthCredentials &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.expiresAt == expiresAt &&
        _listEquals(other.scopes, scopes);
  }

  @override
  int get hashCode {
    return Object.hash(
      accessToken,
      refreshToken,
      expiresAt,
      Object.hashAll(scopes),
    );
  }

  @override
  String toString() {
    return 'OAuthCredentials(accessToken: ${_maskToken(accessToken)}, '
        'refreshToken: ${_maskToken(refreshToken)}, expiresAt: $expiresAt, '
        'scopes: $scopes, isExpired: $isExpired)';
  }

  /// Mask sensitive token data for logging
  static String _maskToken(String token) {
    if (token.length <= 8) return '***';
    return '${token.substring(0, 4)}...${token.substring(token.length - 4)}';
  }

  /// Helper method to compare lists
  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
