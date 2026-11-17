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

  Future<void> _editDetails() async {
    final details = await showDialog<_TitleHeaderDetails>(
      context: context,
      builder: (context) => _TitleHeaderEditDialog(
        title: _title,
        venue: _venue,
        date: _date,
        time: _time,
      ),
    );

    if (details == null || !mounted) return;
    setState(() {
      _title = details.title;
      _venue = details.venue;
      _date = details.date;
      _time = details.time;
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
    if (compact) {
      return Wrap(
        spacing: 10,
        runSpacing: 2,
        children: [
          _metadataItem(Icons.location_on_rounded, _venue, compact: true),
          _metadataItem(
            Icons.calendar_month_outlined,
            _formatDate(_date),
            compact: true,
          ),
          _metadataItem(
            Icons.access_time_rounded,
            _formatTime(_time),
            compact: true,
          ),
        ],
      );
    }

    return Row(
      children: [
        _metadataItem(Icons.location_on_rounded, _venue, compact: false),
        const SizedBox(width: 16),
        Container(width: 1, height: 19, color: const Color(0xFF486182)),
        const SizedBox(width: 16),
        _metadataItem(
          Icons.calendar_month_outlined,
          _formatDate(_date),
          compact: false,
        ),
        const SizedBox(width: 12),
        const Text(
          '•',
          style: TextStyle(color: Color(0xFFE7EDF7), fontSize: 15),
        ),
        const SizedBox(width: 12),
        _metadataItem(
          Icons.access_time_rounded,
          _formatTime(_time),
          compact: false,
        ),
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

  const _TitleHeaderDetails({
    required this.title,
    required this.venue,
    required this.date,
    required this.time,
  });
}

class _TitleHeaderEditDialog extends StatefulWidget {
  final String title;
  final String venue;
  final DateTime date;
  final TimeOfDay time;

  const _TitleHeaderEditDialog({
    required this.title,
    required this.venue,
    required this.date,
    required this.time,
  });

  @override
  State<_TitleHeaderEditDialog> createState() => _TitleHeaderEditDialogState();
}

class _TitleHeaderEditDialogState extends State<_TitleHeaderEditDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _venueController;
  late DateTime _date;
  late TimeOfDay _time;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _venueController = TextEditingController(text: widget.venue);
    _date = widget.date;
    _time = widget.time;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Match Details'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _venueController,
              decoration: const InputDecoration(
                labelText: 'Venue',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() => _date = selectedDate);
                      }
                    },
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(_formatDate(_date)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: _time,
                      );
                      if (selectedTime != null) {
                        setState(() => _time = selectedTime);
                      }
                    },
                    icon: const Icon(Icons.schedule_rounded),
                    label: Text(_formatTime(_time)),
                  ),
                ),
              ],
            ),
            if (_validationMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _validationMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.trim().isEmpty ||
                _venueController.text.trim().isEmpty) {
              setState(
                () =>
                    _validationMessage = 'Enter both an event title and venue.',
              );
              return;
            }
            Navigator.pop(
              context,
              _TitleHeaderDetails(
                title: _titleController.text.trim(),
                venue: _venueController.text.trim(),
                date: _date,
                time: _time,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
