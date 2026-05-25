// ignore_for_file: public_member_api_docs

enum FrameRefreshRate {
  fps24(24, 41667),
  fps60(60, 16667),
  fps90(90, 11111),
  fps120(120, 8333),
  ;

  const FrameRefreshRate(this.fps, this.microseconds);

  static Duration get preset => fps60.duration;

  final int fps;
  final int microseconds;

  Duration get duration => Duration(microseconds: microseconds);
}
