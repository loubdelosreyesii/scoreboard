import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class ResponsiveCounterPage extends StatefulWidget {
  const ResponsiveCounterPage({Key? key}) : super(key: key);

  @override
  State<ResponsiveCounterPage> createState() => _ResponsiveCounterPageState();
}

class _ResponsiveCounterPageState extends State<ResponsiveCounterPage> {
  int _redCount = 0;
  int _blueCount = 0;

  final TextEditingController _redTeamController = TextEditingController(text: 'Team Red');
  final TextEditingController _blueTeamController = TextEditingController(text: 'Team Blue');
  final GlobalKey<_MatchTimerState> _timerKey = GlobalKey<_MatchTimerState>();
  void _incrementRed() {
    setState(() {
      _redCount++;
    });
  }

  void _incrementBlue() {
    setState(() {
      _blueCount++;
    });
  }

  void _decrementRed() {
    if (_redCount > 0) {
      setState(() {
        _redCount--;
      });
    }
  }

  void _decrementBlue() {
    if (_blueCount > 0) {
      setState(() {
        _blueCount--;
      });
    }
  }

  void _resetScores() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reset Scoreboard'),
      content: const Text(
        'Are you sure you want to reset both scores to zero?',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);

            setState(() {
              _redCount = 0;
              _blueCount = 0;
            });
            _timerKey.currentState?.resetTimer();
          },
          child: const Text('Reset'),
        ),
      ],
    ),
  );
}

  @override
  void dispose() {
    _redTeamController.dispose();
    _blueTeamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _resetScores,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        tooltip: 'Reset Scores',
        child: const Icon(Icons.refresh, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              final children = [
                _CounterBox(
                  color: Colors.red.shade400,
                  count: _redCount,
                  onTap: _incrementRed,
                  onLongPress: _decrementRed,
                  teamController: _redTeamController,
                ),
                _CounterBox(
                  color: Colors.blue.shade400,
                  count: _blueCount,
                  onTap: _incrementBlue,
                  onLongPress: _decrementBlue,
                  teamController: _blueTeamController,
                ),
              ];

              return Stack(
                children: [
                  orientation == Orientation.portrait
                      ? Column(children: children)
                      : Row(children: children),
                      
                  Align(
                    alignment: orientation == Orientation.portrait
                        ? Alignment.center
                        : Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: orientation == Orientation.landscape ? 24.0 : 0,
                      ),
                      child: _MatchTimer(key:_timerKey),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// Match Timer Widget
// ---------------------------------------------------------
class _MatchTimer extends StatefulWidget {
  const _MatchTimer({Key? key}) : super(key: key);

  @override
  State<_MatchTimer> createState() => _MatchTimerState();
}

class _MatchTimerState extends State<_MatchTimer> {
  int _seconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  
  bool _isCountdown = false;
  int _countdownMinutes = 10;

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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              // Wrap the Column in SingleChildScrollView to prevent overflow!
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text('Countdown Mode'),
                      subtitle: Text(_isCountdown ? 'Counting down' : 'Counting up'),
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
                          setDialogState(() => _countdownMinutes = value.toInt());
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

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.only(left: 20, right: 12, top: 12, bottom: 12),
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
          Container(
            height: 32,
            width: 1,
            color: Colors.white30,
          ),
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

// ---------------------------------------------------------
// Existing Counter Box Widget
// ---------------------------------------------------------
class _CounterBox extends StatelessWidget {
  final Color color;
  final int count;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final TextEditingController teamController;

  const _CounterBox({
    Key? key,
    required this.color,
    required this.count,
    required this.onTap,
    required this.onLongPress,
    required this.teamController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
              child: TextField(
                controller: teamController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter Team Name',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  border: InputBorder.none,
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: onTap,
                onLongPress: onLongPress,
                child: Center(
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}