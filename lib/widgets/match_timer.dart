import 'dart:async';

import 'package:flutter/material.dart';

class MatchTimer extends StatefulWidget {
  final bool compactLandscapeDesign;
  final VoidCallback? onResetTap;

  const MatchTimer({
    super.key,
    this.compactLandscapeDesign = false,
    this.onResetTap,
  });

  @override
  State<MatchTimer> createState() => MatchTimerState();
}

class MatchTimerState extends State<MatchTimer> {
  int _seconds = 0;
  Timer? _timer;
  bool _isRunning = false;

  bool _isCountdown = false;
  int _countdownMinutes = 10;

  bool get isRunning => _isRunning;

  @override
  void initState() {
    super.initState();
    _initializeTime();
  }

  void resetTimer() {
    _resetTimer();
  }

  void _initializeTime() {
    _seconds = _isCountdown ? _countdownMinutes * 60 : 0;
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      if (_isCountdown && _seconds <= 0) return;

      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_isCountdown) {
            if (_seconds > 0) {
              _seconds--;
            } else {
              _timer?.cancel();
              _isRunning = false;
            }
          } else {
            _seconds++;
          }
        });
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _initializeTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Timer Settings'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              // Wrap the Column in SingleChildScrollView to prevent overflow!
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text('Countdown Mode'),
                      subtitle: Text(
                        _isCountdown ? 'Counting down' : 'Counting up',
                      ),
                      value: _isCountdown,
                      onChanged: (value) {
                        setDialogState(() => _isCountdown = value);
                        setState(() {
                          _isCountdown = value;
                          _resetTimer();
                        });
                      },
                    ),
                    if (_isCountdown) ...[
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Start Time: $_countdownMinutes min',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: _countdownMinutes.toDouble(),
                        min: 1,
                        max: 90,
                        divisions: 89,
                        label: '$_countdownMinutes min',
                        onChanged: (value) {
                          setDialogState(
                            () => _countdownMinutes = value.toInt(),
                          );
                          setState(() {
                            _countdownMinutes = value.toInt();
                            _resetTimer();
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done', style: TextStyle(fontSize: 16)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String get _formattedTime {
    int m = _seconds ~/ 60;
    int s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildLandscapeTimer() {
    return Row(
      children: [
        // Start/pause button
        Material(
          color: const Color(0xFF00C881),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: _toggleTimer,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Timer display
        Expanded(
          child: InkWell(
            onTap: _openSettings,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                _formattedTime,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Reset timer button
        Tooltip(
          message: widget.onResetTap == null
              ? 'Reset Timer'
              : 'Reset Scoreboard',
          child: Material(
            color: const Color(0xFF172638),
            shape: const CircleBorder(
              side: BorderSide(color: Color(0xFF2B4050), width: 1),
            ),
            child: InkWell(
              onTap: widget.onResetTap ?? _resetTimer,
              onLongPress: _openSettings,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons.restart_alt_rounded,
                  color: Color(0xFFE6EDF3),
                  size: 23,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compactLandscapeDesign) {
      return _buildLandscapeTimer();
    }
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(30),
      color: Colors.black87,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _toggleTimer,
            onLongPress: _resetTimer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 12,
                top: 12,
                bottom: 12,
              ),
              child: Row(
                children: [
                  Icon(
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formattedTime,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(height: 32, width: 1, color: Colors.white30),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: _openSettings,
            tooltip: 'Timer Settings',
            padding: const EdgeInsets.only(left: 12, right: 20),
          ),
        ],
      ),
    );
  }
}
