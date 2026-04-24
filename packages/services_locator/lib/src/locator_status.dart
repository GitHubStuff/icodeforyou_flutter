// ignore_for_file: public_member_api_docs

enum LocatorStatus {
  failed, // Startup threw. See .error and .stackTrace.
  ready, // Available for retrieval.
  staged, // In the repo map. No registration work has begun. Initial state.
  starting, // Registry is actively registering this service (and its deps)
}
