import 'package:flutter/material.dart';

class CounterBox extends StatelessWidget {
  final Color color;
  final int count;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final TextEditingController teamController;
  final VoidCallback onSettingsTap;
  final bool isLeftTeam;
  final Color textColor;

  const CounterBox({
    super.key,
    required this.color,
    required this.count,
    required this.onTap,
    required this.onLongPress,
    required this.teamController,
    required this.onSettingsTap,
    required this.isLeftTeam,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 24.0,
                left: 16.0,
                right: 16.0,
              ),
              child: Row(
                children: [
                  if (isLeftTeam)
                    IconButton(
                      onPressed: onSettingsTap,
                      icon: Icon(Icons.palette_outlined, color: textColor),
                      tooltip: 'Team Settings',
                    ),
                  Expanded(
                    child: TextField(
                      controller: teamController,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter Team Name',
                        hintStyle: TextStyle(
                          color: textColor.withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (!isLeftTeam)
                    IconButton(
                      onPressed: onSettingsTap,
                      icon: Icon(Icons.palette_outlined, color: textColor),
                      tooltip: 'Team Settings',
                    ),
                ],
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: onTap,
                onLongPress: onLongPress,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final scoreFontSize = constraints.maxWidth * 0.75;

                    return Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: scoreFontSize,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            shadows: const [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
