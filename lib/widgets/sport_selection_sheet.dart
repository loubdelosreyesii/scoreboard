import 'package:flutter/material.dart';

import '../enums/match_segment_type.dart';
import '../models/sport_template.dart';
import '../theme/scoreboard_theme.dart';

class SportSelectionSheet extends StatefulWidget {
  final List<SportTemplate> sportTemplates;
  final SportTemplate selectedSport;
  final ValueChanged<SportTemplate> onSportSelected;
  final Future<bool> Function(SportTemplate sport, int segmentCount)
  onSegmentCountChanged;

  const SportSelectionSheet({
    super.key,
    required this.sportTemplates,
    required this.selectedSport,
    required this.onSportSelected,
    required this.onSegmentCountChanged,
  });

  @override
  State<SportSelectionSheet> createState() => _SportSelectionSheetState();
}

class _SportSelectionSheetState extends State<SportSelectionSheet> {
  static const List<int> _availableSetCounts = [1, 3, 5, 7];

  late final List<SportTemplate> _sportTemplates;

  @override
  void initState() {
    super.initState();
    _sportTemplates = List.of(widget.sportTemplates);
  }

  Future<void> _changeSegmentCount(
    SportTemplate sport,
    int segmentCount,
  ) async {
    if (sport.segmentCount == segmentCount) return;

    final didUpdate = await widget.onSegmentCountChanged(sport, segmentCount);
    if (!didUpdate || !mounted) return;

    final index = _sportTemplates.indexWhere(
      (template) => template.name == sport.name,
    );
    setState(() {
      _sportTemplates[index] = sport.copyWith(segmentCount: segmentCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: scoreboardBackgroundGradient,
          border: Border(
            top: BorderSide(color: scoreboardBackgroundBorderColor),
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF91A4BC),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Sport',
                            style: TextStyle(
                              color: scoreboardDialogTextColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Choose a sport for this match.',
                            style: TextStyle(
                              color: scoreboardDialogMutedTextColor,
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
                const SizedBox(height: 12),
                ..._sportTemplates.map(_buildSportTile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSportTile(SportTemplate sport) {
    final isSelected = widget.selectedSport.name == sport.name;
    final hasSetCount = sport.segmentType == MatchSegmentType.sets;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            widget.onSportSelected(sport);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? scoreboardDialogSurfaceColor
                  : scoreboardDialogBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? scoreboardAccentColor
                    : scoreboardDialogBorderColor,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sport.name,
                        style: const TextStyle(
                          color: scoreboardDialogTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        sport.segmentLabel,
                        style: const TextStyle(
                          color: scoreboardDialogMutedTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasSetCount) ...[
                  const Tooltip(
                    message: 'Number of sets',
                    child: Text(
                      'Sets',
                      style: TextStyle(
                        color: scoreboardDialogMutedTextColor,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  _buildSetCountDropdown(sport),
                ],
                if (isSelected) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: scoreboardAccentColor,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetCountDropdown(SportTemplate sport) {
    return DropdownButton<int>(
      key: ValueKey('set-count-${sport.name}'),
      value: sport.segmentCount,
      isDense: true,
      underline: const SizedBox.shrink(),
      dropdownColor: scoreboardDialogSurfaceColor,
      iconEnabledColor: scoreboardDialogMutedTextColor,
      style: const TextStyle(color: scoreboardDialogTextColor, fontSize: 13),
      items: _availableSetCounts
          .map(
            (count) => DropdownMenuItem(
              value: count,
              child: Text(
                '$count',
                style: const TextStyle(color: scoreboardDialogTextColor),
              ),
            ),
          )
          .toList(),
      onChanged: (count) {
        if (count != null) _changeSegmentCount(sport, count);
      },
    );
  }
}
