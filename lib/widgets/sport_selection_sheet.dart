import 'package:flutter/material.dart';

import '../enums/match_segment_type.dart';
import '../models/sport_template.dart';

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
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Sport',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._sportTemplates.map(
                (sport) => ListTile(
                  title: Text(sport.name),
                  subtitle: Text(sport.segmentLabel),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (sport.segmentType == MatchSegmentType.sets) ...[
                        const Tooltip(
                          message: 'Number of sets',
                          child: Text('Sets'),
                        ),
                        DropdownButton<int>(
                          key: ValueKey('set-count-${sport.name}'),
                          value: sport.segmentCount,
                          isDense: true,
                          underline: const SizedBox.shrink(),
                          items: _availableSetCounts
                              .map(
                                (count) => DropdownMenuItem(
                                  value: count,
                                  child: Text('$count'),
                                ),
                              )
                              .toList(),
                          onChanged: (count) {
                            if (count != null) {
                              _changeSegmentCount(sport, count);
                            }
                          },
                        ),
                      ],
                      if (widget.selectedSport.name == sport.name)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                  onTap: () {
                    widget.onSportSelected(sport);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
