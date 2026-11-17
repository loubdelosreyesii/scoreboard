import 'package:flutter/material.dart';

import '../models/sport_template.dart';

class SportSelectionSheet extends StatelessWidget {
  final List<SportTemplate> sportTemplates;
  final SportTemplate selectedSport;
  final ValueChanged<SportTemplate> onSportSelected;

  const SportSelectionSheet({
    super.key,
    required this.sportTemplates,
    required this.selectedSport,
    required this.onSportSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            ...sportTemplates.map(
              (sport) => ListTile(
                title: Text(sport.name),
                subtitle: Text(sport.segmentLabel),
                trailing: selectedSport == sport
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  onSportSelected(sport);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
