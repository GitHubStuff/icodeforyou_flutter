// ignore_for_file: public_member_api_docs

enum FrameRefreshRate {
  fps24(24, 42),
  fps60(60, 17),
  fps90(90, 12),
  fps120(120, 9),
  ;

  const FrameRefreshRate(this.fps, this.fpms);

  final int fps;
  final int fpms;
}
