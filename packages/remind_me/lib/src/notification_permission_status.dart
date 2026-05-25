// packages/remind_me/lib/src/notification_permission_status.dart

/// The current state of the OS notification permission for this app.
///
/// Decouples callers from `permission_handler`'s `PermissionStatus`
/// shape, so the choice of underlying permission library is a private
/// detail of the [RemindMe] wrapper. UIs `switch` on this enum to pick
/// the right action ("request" vs "open settings" vs "nothing to do").
enum NotificationPermissionStatus {
  /// Permission has been granted by the user. Notifications can be
  /// scheduled and delivered.
  granted,

  /// Permission has been denied for the current session, but the user
  /// can be prompted again. The "Request" action is still meaningful
  /// from this state.
  denied,

  /// Permission has been denied permanently — typically because the
  /// user selected "Don't ask again" on Android, or has previously
  /// denied on iOS where the OS will no longer show the prompt. The
  /// only path forward is the OS settings screen.
  permanentlyDenied,

  /// On Android, the OS has restricted notifications for this app via
  /// parental controls or device policy. Distinct from
  /// [permanentlyDenied] because the user typically cannot grant from
  /// settings without an administrator's intervention.
  restricted,

  /// Permission has not yet been requested. The first
  /// [RemindMe.requestPermissions] call will prompt.
  notDetermined,
}
