import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TeamColorSettingsSheet extends StatefulWidget {
  final String teamName;
  final Color currentColor;
  final Color defaultColor;
  final String defaultColorDescription;
  final List<Color> availableColors;
  final Future<void> Function(Color color) onColorChanged;

  const TeamColorSettingsSheet({
    super.key,
    required this.teamName,
    required this.currentColor,
    required this.defaultColor,
    required this.defaultColorDescription,
    required this.availableColors,
    required this.onColorChanged,
  });

  @override
  State<TeamColorSettingsSheet> createState() => _TeamColorSettingsSheetState();
}

class _TeamColorSettingsSheetState extends State<TeamColorSettingsSheet> {
  late Color _selectedColor = widget.currentColor;
  late Color _pickerColor = widget.currentColor;

  Future<void> _selectColor(Color color) async {
    await widget.onColorChanged(color);
    if (!mounted) return;
    setState(() => _selectedColor = color);
  }

  Future<void> _applyCustomColor(BuildContext dialogContext) async {
    await widget.onColorChanged(_pickerColor);
    if (!mounted || !dialogContext.mounted) return;
    setState(() => _selectedColor = _pickerColor);
    Navigator.pop(dialogContext);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.teamName} Settings',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Choose Team Color'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: widget.availableColors.map((color) {
                final isSelected = _selectedColor == color;
                final checkColor = color.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white;

                return InkWell(
                  onTap: () => _selectColor(color),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: isSelected ? 4 : 1,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade400,
                      ),
                      boxShadow: [
                        if (isSelected)
                          const BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                      ],
                    ),
                    child: isSelected
                        ? Icon(Icons.check, color: checkColor, size: 24)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Custom Color'),
              subtitle: const Text('Choose any color'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Choose Team Color'),
                    content: StatefulBuilder(
                      builder: (context, setPickerState) {
                        return SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: _pickerColor,
                            onColorChanged: (color) {
                              setPickerState(() => _pickerColor = color);
                            },
                          ),
                        );
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => _applyCustomColor(dialogContext),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: const Text('Reset to Default'),
              subtitle: Text(widget.defaultColorDescription),
              onTap: () => _selectColor(widget.defaultColor),
            ),
          ],
        ),
      ),
    );
  }
}
