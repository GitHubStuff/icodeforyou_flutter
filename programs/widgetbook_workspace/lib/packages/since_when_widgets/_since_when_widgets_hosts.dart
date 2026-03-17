// lib/packages/since_when_widgets/_since_when_widgets_hosts.dart

part of 'since_when_widgets.usecase.dart';

// ---------------------------------------------------------------------------
// _LiveOutputHost — CountedTextField
// ---------------------------------------------------------------------------

class _LiveOutputHost extends StatefulWidget {
  const _LiveOutputHost({
    required this.maxLength,
    required this.hintText,
    this.caption,
  });

  final int maxLength;
  final String? caption;
  final String hintText;

  @override
  State<_LiveOutputHost> createState() => _LiveOutputHostState();
}

class _LiveOutputHostState extends State<_LiveOutputHost> {
  var _output = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CountedTextField(
            onChanged: (value) => setState(() => _output = value),
            maxLength: widget.maxLength,
            caption: widget.caption,
            hintText: widget.hintText,
          ),
          const SizedBox(height: 24),
          Text(
            'onChanged → "$_output"',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'length: ${_output.length} / ${widget.maxLength}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _TruncationHost — CountedTextField
// ---------------------------------------------------------------------------

class _TruncationHost extends StatefulWidget {
  const _TruncationHost();

  @override
  State<_TruncationHost> createState() => _TruncationHostState();
}

class _TruncationHostState extends State<_TruncationHost> {
  var _output = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Max 5 characters — paste or type past the limit to see '
            'truncation and the floating message.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          CountedTextField(
            onChanged: (value) => setState(() => _output = value),
            maxLength: 5,
            caption: 'Short Field',
            durationMs: 1500,
            fadeMs: 400,
          ),
          const SizedBox(height: 24),
          Text(
            'Returned: "$_output"',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _CaptionShowcase — CountedTextField
// ---------------------------------------------------------------------------

class _CaptionShowcase extends StatelessWidget {
  const _CaptionShowcase();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _sectionLabel(context, 'No caption'),
          const SizedBox(height: 8),
          const CountedTextField(onChanged: _noOp),
          const SizedBox(height: 32),
          _sectionLabel(context, 'With caption — LTR'),
          const SizedBox(height: 8),
          const CountedTextField(
            onChanged: _noOp,
            caption: 'First Name',
          ),
          const SizedBox(height: 32),
          _sectionLabel(context, 'With caption — RTL'),
          const SizedBox(height: 8),
          const CountedTextField(
            onChanged: _noOp,
            caption: 'الاسم الأول',
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _HintTextShowcase — CountedTextField
// ---------------------------------------------------------------------------

class _HintTextShowcase extends StatelessWidget {
  const _HintTextShowcase();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _sectionLabel(context, 'Default hint — "Enter Text"'),
          const SizedBox(height: 8),
          const CountedTextField(onChanged: _noOp),
          const SizedBox(height: 32),
          _sectionLabel(context, 'Custom hint'),
          const SizedBox(height: 8),
          const CountedTextField(
            onChanged: _noOp,
            caption: 'Search',
            hintText: 'Type to search...',
          ),
          const SizedBox(height: 32),
          _sectionLabel(context, 'No hint'),
          const SizedBox(height: 8),
          const CountedTextField(
            onChanged: _noOp,
            hintText: '',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _TagColorLiveOutputHost — TagColorField
// ---------------------------------------------------------------------------

class _TagColorLiveOutputHost extends StatefulWidget {
  const _TagColorLiveOutputHost({required this.height});

  final double height;

  @override
  State<_TagColorLiveOutputHost> createState() =>
      _TagColorLiveOutputHostState();
}

class _TagColorLiveOutputHostState extends State<_TagColorLiveOutputHost> {
  int? _current;
  final _history = <int>[];

  void _onChanged(int value) {
    setState(() {
      _current = value;
      if (!_history.contains(value)) _history.add(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TagColorField(
            onChanged: _onChanged,
            height: widget.height,
          ),
          const SizedBox(height: 24),
          Text(
            'Current color → '
            // ignore: lines_longer_than_80_chars
            '${_current == null ? '—' : '#${_current!.toRadixString(16).toUpperCase().padLeft(8, '0')}'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Colors excluded so far: ${_history.length}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _TagColorSkipHost — TagColorField
// ---------------------------------------------------------------------------

class _TagColorSkipHost extends StatefulWidget {
  const _TagColorSkipHost();

  @override
  State<_TagColorSkipHost> createState() => _TagColorSkipHostState();
}

class _TagColorSkipHostState extends State<_TagColorSkipHost> {
  final _pickedColors = <int>[];

  void _onChanged(int value) {
    setState(() {
      if (!_pickedColors.contains(value)) _pickedColors.add(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Each refresh permanently excludes the previous color. '
            'Picked colors are shown below as swatches.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          TagColorField(
            onChanged: _onChanged,
            skipColors: _pickedColors,
          ),
          const SizedBox(height: 24),
          _sectionLabel(context, 'Excluded colors (${_pickedColors.length})'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _pickedColors.map((c) {
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(c),
                  border: Border.all(color: Colors.grey.shade400),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
