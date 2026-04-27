class Config {
  /// Base URL for backend key retrieval used by `KeyService`.
  /// For local development we point to the small key server started at port 3000.
  /// Change this if your server runs elsewhere or to `'/api'` for same-origin deployments.
  static const String backendBaseUrl = 'http://localhost:3000/api';
}
