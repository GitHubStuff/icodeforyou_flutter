// lib/packages/scrolling_datetime_pickers/_datetime_popover_theme_showcase.dart

part of 'scrolling_datetime_pickers_widgetbook.dart';

class _DateTimePopoverThemeShowcase extends StatefulWidget {
  const _DateTimePopoverThemeShowcase();

  @override
  State<_DateTimePopoverThemeShowcase> createState() =>
      _DateTimePopoverThemeShowcaseState();
}

class _DateTimePopoverThemeShowcaseState
    extends State<_DateTimePopoverThemeShowcase> {
  final GlobalKey _lightAnchorKey = GlobalKey();
  final GlobalKey _darkAnchorKey = GlobalKey();
  DateTime? _lightSelectedDateTime;
  DateTime? _darkSelectedDateTime;

  Future<void> _showLightPopover() async {
    final result = await DateTimePickerPopover.show(
      context: context,
      anchorKey: _lightAnchorKey,
      initialDateTime: _lightSelectedDateTime ?? DateTime.now(),
      popoverBackgroundColor: const Color(0xFFF5F5F5),
      pickerBackgroundColor: Colors.white,
      headerDateTextStyle: const TextStyle(
        color: Colors.black87,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      headerTimeTextStyle: const TextStyle(color: Colors.black87, fontSize: 18),
      dateButtonColor: Colors.blue,
      timeButtonColor: Colors.purple,
      dateButtonTextStyle: const TextStyle(color: Colors.black87),
      timeButtonTextStyle: const TextStyle(color: Colors.black87),
      dateStyle: const TextStyle(color: Colors.black87, fontSize: 20),
      timeStyle: const TextStyle(color: Colors.black87, fontSize: 20),
      fadeConfiguration: FadeConfiguration.light(),
      dividerConfiguration: const DividerConfiguration(color: Colors.black12),
    );

    if (result != null) {
      setState(() {
        _lightSelectedDateTime = result;
      });
    }
  }

  Future<void> _showDarkPopover() async {
    final result = await DateTimePickerPopover.show(
      context: context,
      anchorKey: _darkAnchorKey,
      initialDateTime: _darkSelectedDateTime ?? DateTime.now(),
      popoverBackgroundColor: const Color(0xFF2D2D2D),
      pickerBackgroundColor: const Color(0xFF1E1E1E),
      headerDateTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      headerTimeTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
      dateButtonColor: Colors.cyanAccent,
      timeButtonColor: Colors.pinkAccent,
      dateButtonTextStyle: const TextStyle(color: Colors.white),
      timeButtonTextStyle: const TextStyle(color: Colors.white),
      dateStyle: const TextStyle(color: Colors.white, fontSize: 20),
      timeStyle: const TextStyle(color: Colors.white, fontSize: 20),
      fadeConfiguration: FadeConfiguration.dark(),
      confirmButtonColor: Colors.tealAccent,
      confirmButtonTextStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
    );

    if (result != null) {
      setState(() {
        _darkSelectedDateTime = result;
      });
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Tap to select';
    return DateFormat('EEE, dd-MMM-yyyy\nhh:mm:ss a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Theme Showcase', style: theme.textTheme.titleLarge),
        const Gap(24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text('Light Theme'),
                const Gap(8),
                GestureDetector(
                  key: _lightAnchorKey,
                  onTap: _showLightPopover,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      _formatDateTime(_lightSelectedDateTime),
                      style: const TextStyle(color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const Text('Dark Theme'),
                const Gap(8),
                GestureDetector(
                  key: _darkAnchorKey,
                  onTap: _showDarkPopover,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade800),
                    ),
                    child: Text(
                      _formatDateTime(_darkSelectedDateTime),
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
