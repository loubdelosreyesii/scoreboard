import 'package:flutter/material.dart';

import '../theme/scoreboard_theme.dart';

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')} '
      '${_months[date.month - 1]} ${date.year}';
}

String _formatTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
}

class TitleHeader extends StatefulWidget {
  const TitleHeader({super.key});

  @override
  State<TitleHeader> createState() => _TitleHeaderState();
}

class _TitleHeaderState extends State<TitleHeader> {
  String _title = 'CITY TABLE TENNIS CUP 2026';
  String _venue = 'Pasig Sports Center';
  DateTime _date = DateTime(2026, 10, 24);
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  bool _showHeader = true;

  Future<void> _editDetails() async {
    final details = await showDialog<_TitleHeaderDetails>(
      context: context,
      builder: (context) => _TitleHeaderEditDialog(
        title: _title,
        venue: _venue,
        date: _date,
        time: _time,
        showHeader: _showHeader,
      ),
    );

    if (details == null || !mounted) return;
    setState(() {
      _title = details.title;
      _venue = details.venue;
      _date = details.date;
      _time = details.time;
      _showHeader = details.showHeader;
    });
  }

  Widget _metadataItem(IconData icon, String text, {required bool compact}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: compact ? 13 : 17, color: const Color(0xFFE7EDF7)),
        SizedBox(width: compact ? 4 : 7),
        Text(
          text,
          style: TextStyle(
            color: const Color(0xFFE7EDF7),
            fontSize: compact ? 10 : 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMetadata({required bool compact}) {
    final metadata = <Widget>[
      if (_venue.isNotEmpty)
        _metadataItem(Icons.location_on_rounded, _venue, compact: compact),
      _metadataItem(
        Icons.calendar_month_outlined,
        _formatDate(_date),
        compact: compact,
      ),
      _metadataItem(
        Icons.access_time_rounded,
        _formatTime(_time),
        compact: compact,
      ),
    ];

    if (compact) {
      return Wrap(spacing: 10, runSpacing: 2, children: metadata);
    }

    return Row(
      children: [
        if (_venue.isNotEmpty) ...[
          metadata[0],
          const SizedBox(width: 16),
          Container(width: 1, height: 19, color: const Color(0xFF486182)),
          const SizedBox(width: 16),
        ],
        metadata[_venue.isEmpty ? 0 : 1],
        const SizedBox(width: 12),
        const Text(
          '•',
          style: TextStyle(color: Color(0xFFE7EDF7), fontSize: 15),
        ),
        const SizedBox(width: 12),
        metadata[_venue.isEmpty ? 1 : 2],
      ],
    );
  }

  Widget _buildEditButton({required bool compact}) {
    return Tooltip(
      message: 'Edit match details',
      child: Material(
        color: const Color(0xFF19345A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
          side: const BorderSide(color: Color(0xFF3D5C83), width: 1),
        ),
        child: InkWell(
          onTap: _editDetails,
          borderRadius: BorderRadius.circular(9),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 9 : 16,
              vertical: compact ? 9 : 13,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_rounded,
                  size: compact ? 16 : 19,
                  color: Colors.white,
                ),
                SizedBox(width: compact ? 5 : 8),
                Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 13 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_showHeader) {
      return Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          onPressed: _editDetails,
          tooltip: 'Edit tournament header',
          icon: const Icon(Icons.edit_rounded, color: Colors.white),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 850;

        return Container(
          height: compact ? 90 : 86,
          padding: EdgeInsets.only(
            left: compact ? 14 : 36,
            right: compact ? 14 : 8,
          ),
          decoration: const BoxDecoration(
            gradient: scoreboardBackgroundGradient,
            border: Border(
              bottom: BorderSide(color: scoreboardBackgroundBorderColor),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                size: compact ? 34 : 56,
                color: Colors.white,
              ),
              SizedBox(width: compact ? 12 : 30),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 17 : 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: compact ? 0 : 0.3,
                      ),
                    ),
                    SizedBox(height: compact ? 3 : 5),
                    _buildMetadata(compact: compact),
                  ],
                ),
              ),
              SizedBox(width: compact ? 8 : 20),
              _buildEditButton(compact: compact),
            ],
          ),
        );
      },
    );
  }
}

class _TitleHeaderDetails {
  final String title;
  final String venue;
  final DateTime date;
  final TimeOfDay time;
  final bool showHeader;

  const _TitleHeaderDetails({
    required this.title,
    required this.venue,
    required this.date,
    required this.time,
    required this.showHeader,
  });
}

class _TitleHeaderEditDialog extends StatefulWidget {
  final String title;
  final String venue;
  final DateTime date;
  final TimeOfDay time;
  final bool showHeader;

  const _TitleHeaderEditDialog({
    required this.title,
    required this.venue,
    required this.date,
    required this.time,
    required this.showHeader,
  });

  @override
  State<_TitleHeaderEditDialog> createState() => _TitleHeaderEditDialogState();
}

class _TitleHeaderEditDialogState extends State<_TitleHeaderEditDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _venueController;
  late DateTime _date;
  late TimeOfDay _time;
  late bool _showHeader;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _venueController = TextEditingController(text: widget.venue);
    _date = widget.date;
    _time = widget.time;
    _showHeader = widget.showHeader;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: screenSize.height * 0.92,
        ),
        child: Container(
          width: 480,
          decoration: BoxDecoration(
            color: const Color(0xFF0B1B2E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF294663)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Edit tournament header',
                            style: TextStyle(
                              color: Color(0xFFF2F5FA),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Update the details shown above your scoreboard.',
                            style: TextStyle(
                              color: Colors.blueGrey.shade200,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.close,
                        size: 19,
                        color: Color(0xFFB8C6D9),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLivePreview(),
                      const SizedBox(height: 12),
                      _buildTitleField(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${_titleController.text.length}/80',
                          style: const TextStyle(
                            color: Color(0xFF91A4BC),
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      _buildVenueField(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPickerField(
                              label: 'Date',
                              icon: Icons.calendar_month_outlined,
                              value: _formatDate(_date),
                              onTap: _pickDate,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildPickerField(
                              label: 'Time',
                              icon: Icons.access_time_rounded,
                              value: _formatTime(_time),
                              onTap: _pickTime,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Location, date and time appear as the subtitle.',
                        style: TextStyle(
                          color: Colors.blueGrey.shade300,
                          fontSize: 10,
                        ),
                      ),
                      if (_validationMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _validationMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 13),
                      const Divider(color: Color(0xFF243B54), height: 1),
                      const SizedBox(height: 12),
                      _buildVisibilityToggle(),
                    ],
                  ),
                ),
              ),
              const Divider(color: Color(0xFF243B54), height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE5ECF5),
                          side: const BorderSide(color: Color(0xFF385675)),
                          minimumSize: const Size.fromHeight(38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0CBE78),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save changes',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLivePreview() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
      decoration: BoxDecoration(
        color: const Color(0xFF10243A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF203B59)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 2, bottom: 7),
            child: Text(
              'LIVE PREVIEW',
              style: TextStyle(
                color: Color(0xFF91A9C6),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.7,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1B2E),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titleController.text.trim().isEmpty
                            ? 'Tournament title'
                            : _titleController.text.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFF0F3F8),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 3,
                        children: [
                          if (_venueController.text.trim().isNotEmpty)
                            _previewMetadata(
                              Icons.location_on_rounded,
                              _venueController.text.trim(),
                            ),
                          _previewMetadata(
                            Icons.calendar_month_outlined,
                            _formatDate(_date),
                          ),
                          _previewMetadata(
                            Icons.access_time_rounded,
                            _formatTime(_time),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewMetadata(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: const Color(0xFFE7EDF7)),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(color: Color(0xFFE7EDF7), fontSize: 9),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _EditFieldLabel(text: 'Tournament title', requiredField: true),
        const SizedBox(height: 5),
        TextField(
          controller: _titleController,
          maxLength: 80,
          onChanged: (_) => setState(() => _validationMessage = null),
          style: const TextStyle(color: Color(0xFFE7EDF7), fontSize: 12),
          buildCounter:
              (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null,
          decoration: _fieldDecoration(),
        ),
      ],
    );
  }

  Widget _buildVenueField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _EditFieldLabel(text: 'Location'),
        const SizedBox(height: 5),
        TextField(
          controller: _venueController,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: Color(0xFFE7EDF7), fontSize: 12),
          decoration: _fieldDecoration(
            prefixIcon: const Icon(
              Icons.location_on_rounded,
              size: 16,
              color: Color(0xFFB8C6D9),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration({Widget? prefixIcon}) {
    return InputDecoration(
      prefixIcon: prefixIcon,
      counterText: '',
      isDense: true,
      filled: true,
      fillColor: const Color(0xFF0B1B2E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF294663)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF4E83B5)),
      ),
    );
  }

  Widget _buildPickerField({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EditFieldLabel(text: label),
        const SizedBox(height: 5),
        Material(
          color: const Color(0xFF0B1B2E),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF294663)),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 15, color: const Color(0xFFB8C6D9)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFE7EDF7),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilityToggle() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Show tournament header',
                style: TextStyle(
                  color: Color(0xFFE7EDF7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Visible in operator and display modes.',
                style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 10),
              ),
            ],
          ),
        ),
        Switch(
          value: _showHeader,
          activeThumbColor: Colors.white,
          activeTrackColor: const Color(0xFF0CBE78),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFF52657A),
          onChanged: (show) => setState(() => _showHeader = show),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) setState(() => _date = selectedDate);
  }

  Future<void> _pickTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (selectedTime != null) setState(() => _time = selectedTime);
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _validationMessage = 'Enter a tournament title.');
      return;
    }

    Navigator.pop(
      context,
      _TitleHeaderDetails(
        title: title,
        venue: _venueController.text.trim(),
        date: _date,
        time: _time,
        showHeader: _showHeader,
      ),
    );
  }
}

class _EditFieldLabel extends StatelessWidget {
  final String text;
  final bool requiredField;

  const _EditFieldLabel({required this.text, this.requiredField = false});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFFCBD6E4),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(text: text),
          if (requiredField)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Color(0xFFFF5B61)),
            ),
        ],
      ),
    );
  }
}
