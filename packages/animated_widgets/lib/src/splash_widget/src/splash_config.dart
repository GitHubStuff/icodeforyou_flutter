// ignore_for_file: public_member_api_docs

const Duration _kDefaultSplashDuration = Duration(seconds: 4);
const Duration _kDefaultTimeout = Duration(seconds: 30);
const Duration _kDefaultCrossfadeDuration = Duration(milliseconds: 300);
const String _kTimeoutText = 'Time Out';
const String _kBackgroundTaskFailedText = 'Background task failed';

final class SplashConfig {
  const SplashConfig({
    this.splashDuration = _kDefaultSplashDuration,
    this.timeoutDuration = _kDefaultTimeout,
    this.crossfadeDuration = _kDefaultCrossfadeDuration,
    this.timeoutText = _kTimeoutText,
    this.backgroundTaskFailedText = _kBackgroundTaskFailedText,
  });
  final Duration splashDuration;
  final Duration timeoutDuration;
  final Duration crossfadeDuration;
  final String timeoutText;
  final String backgroundTaskFailedText;
}
