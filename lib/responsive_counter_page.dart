import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import 'enums/match_segment_type.dart';
import 'models/sport_template.dart';
import 'data/sport_templates.dart';
import 'models/segment_score.dart';
import 'widgets/center_console.dart';
import 'widgets/counter_box.dart';
import 'widgets/match_timer.dart';
import 'widgets/sport_selection_sheet.dart';
import 'widgets/team_color_settings_sheet.dart';

class ResponsiveCounterPage extends StatefulWidget {
  const ResponsiveCounterPage({super.key});

  @override
  State<ResponsiveCounterPage> createState() => _ResponsiveCounterPageState();
}

class _ResponsiveCounterPageState extends State<ResponsiveCounterPage> {
  static const String _redTeamColorKey = 'red_team_color';
  static const String _blueTeamColorKey = 'blue_team_color';

  int _redCount = 0;
  int _blueCount = 0;

  int _redSegmentsWon = 0;
  int _blueSegmentsWon = 0;

  int _currentSegment = 1;
  final List<SegmentScore> _completedSegments = [];

  Color _redTeamColor = Colors.red.shade400;
  Color _blueTeamColor = Colors.blue.shade400;

  SportTemplate _selectedSport = tableTennisTemplate;

  final List<SportTemplate> _sportTemplates = [
    tableTennisTemplate,
    badmintonTemplate,
    volleyballTemplate,
    basketballTemplate,
  ];

  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  final List<Color> _availableColors = [
    Colors.red.shade400,
    Colors.blue.shade400,
    Colors.green.shade400,
    Colors.yellow.shade600,
    Colors.purple.shade400,
    Colors.orange.shade400,
    Colors.black87,
    Colors.white,
  ];

  final TextEditingController _redTeamController = TextEditingController(
    text: 'Team Red',
  );
  final TextEditingController _blueTeamController = TextEditingController(
    text: 'Team Blue',
  );
  final GlobalKey<MatchTimerState> _timerKey = GlobalKey<MatchTimerState>();

  @override
  void initState() {
    super.initState();
    _loadTeamColors();
  }

  Future<void> _loadTeamColors() async {
    final savedRedColor = await _preferences.getInt(_redTeamColorKey);
    final savedBlueColor = await _preferences.getInt(_blueTeamColorKey);

    if (!mounted) return;

    setState(() {
      if (savedRedColor != null) {
        _redTeamColor = Color(savedRedColor);
      }

      if (savedBlueColor != null) {
        _blueTeamColor = Color(savedBlueColor);
      }
    });
  }

  Future<void> _updateTeamColor({
    required bool isLeftTeam,
    required Color color,
  }) async {
    setState(() {
      if (isLeftTeam) {
        _redTeamColor = color;
      } else {
        _blueTeamColor = color;
      }
    });

    final preferenceKey = isLeftTeam ? _redTeamColorKey : _blueTeamColorKey;

    await _preferences.setInt(preferenceKey, color.toARGB32());
  }

  void _incrementRed() {
    if (_isMatchComplete) return;

    setState(() {
      _redCount++;
      _completeSetIfWon();
    });
  }

  void _incrementBlue() {
    if (_isMatchComplete) return;

    setState(() {
      _blueCount++;
      _completeSetIfWon();
    });
  }

  void _decrementRed() {
    if (_redCount > 0) {
      setState(() {
        _redCount--;
      });
    } else {
      _reopenLastSetForCorrection(isLeftTeam: true);
    }
  }

  void _decrementBlue() {
    if (_blueCount > 0) {
      setState(() {
        _blueCount--;
      });
    } else {
      _reopenLastSetForCorrection(isLeftTeam: false);
    }
  }

  bool get _isMatchComplete {
    if (_selectedSport.segmentType != MatchSegmentType.sets ||
        _selectedSport.segmentCount <= 0) {
      return false;
    }

    final setsToWin = _selectedSport.segmentCount ~/ 2 + 1;
    return _redSegmentsWon >= setsToWin ||
        _blueSegmentsWon >= setsToWin ||
        _completedSegments.length >= _selectedSport.segmentCount;
  }

  void _completeSetIfWon() {
    if (_selectedSport.segmentType != MatchSegmentType.sets ||
        _selectedSport.pointsToWin <= 0 ||
        _completedSegments.length >= _selectedSport.segmentCount) {
      return;
    }

    final leftWon =
        _redCount >= _selectedSport.pointsToWin &&
        _redCount - _blueCount >= _selectedSport.winBy;
    final rightWon =
        _blueCount >= _selectedSport.pointsToWin &&
        _blueCount - _redCount >= _selectedSport.winBy;

    if (!leftWon && !rightWon) return;

    _completedSegments.add(
      SegmentScore(
        leftScore: _redCount,
        rightScore: _blueCount,
        leftWon: leftWon,
      ),
    );

    if (leftWon) {
      _redSegmentsWon++;
    } else {
      _blueSegmentsWon++;
    }

    _currentSegment++;
    _redCount = 0;
    _blueCount = 0;
  }

  void _reopenLastSetForCorrection({required bool isLeftTeam}) {
    if (_selectedSport.segmentType != MatchSegmentType.sets ||
        _completedSegments.isEmpty) {
      return;
    }

    final lastSet = _completedSegments.last;
    final scoreToDecrement = isLeftTeam
        ? lastSet.leftScore
        : lastSet.rightScore;
    if (scoreToDecrement == 0) return;

    setState(() {
      _completedSegments.removeLast();
      if (lastSet.leftWon) {
        _redSegmentsWon--;
      } else {
        _blueSegmentsWon--;
      }

      _currentSegment = _completedSegments.length + 1;
      _redCount = lastSet.leftScore - (isLeftTeam ? 1 : 0);
      _blueCount = lastSet.rightScore - (isLeftTeam ? 0 : 1);
      _completeSetIfWon();
    });
  }

  void _resetScores() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Scoreboard'),
        content: const Text(
          'Are you sure you want to reset the scores and set history?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                _redSegmentsWon = 0;
                _blueSegmentsWon = 0;
                _currentSegment = 1;
                _completedSegments.clear();
              });
              _timerKey.currentState?.resetTimer();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showTeamSettings({required bool isLeftTeam}) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => TeamColorSettingsSheet(
        teamName: isLeftTeam
            ? _redTeamController.text
            : _blueTeamController.text,
        currentColor: isLeftTeam ? _redTeamColor : _blueTeamColor,
        defaultColor: isLeftTeam ? Colors.red.shade400 : Colors.blue.shade400,
        defaultColorDescription: isLeftTeam
            ? 'Restore the original red color'
            : 'Restore the original blue color',
        availableColors: _availableColors,
        onColorChanged: (color) =>
            _updateTeamColor(isLeftTeam: isLeftTeam, color: color),
      ),
    );
  }

  void _showSportTemplateDialog() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SportSelectionSheet(
        sportTemplates: _sportTemplates,
        selectedSport: _selectedSport,
        onSportSelected: (sport) {
          setState(() {
            _selectedSport = sport;
            _redCount = 0;
            _blueCount = 0;
            _redSegmentsWon = 0;
            _blueSegmentsWon = 0;
            _currentSegment = 1;
            _completedSegments.clear();
          });

          _timerKey.currentState?.resetTimer();
        },
      ),
    );
  }

  void _toggleFullscreen() {
    if (html.document.fullscreenElement != null) {
      html.document.exitFullscreen();
      return;
    }

    final documentElement = html.document.documentElement;
    if (html.document.fullscreenEnabled != true || documentElement == null) {
      _showFullscreenUnavailableMessage();
      return;
    }

    documentElement.requestFullscreen();
  }

  void _showFullscreenUnavailableMessage() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            "iPhone browsers don't allow fullscreen from a tab. For a cleaner view, use Chrome's Share menu > Add to Home Screen, then open Scoreboard from there.",
          ),
          duration: Duration(seconds: 8),
        ),
      );
  }

  String _getSegmentTitle() {
    switch (_selectedSport.segmentType) {
      case MatchSegmentType.sets:
        return 'Sets';

      case MatchSegmentType.quarters:
        return 'Quarter';

      case MatchSegmentType.periods:
        return 'Period';

      case MatchSegmentType.halves:
        return 'Half';

      case MatchSegmentType.none:
        return 'Segment';
    }
  }

  Color _getTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }

  @override
  void dispose() {
    _redTeamController.dispose();
    _blueTeamController.dispose();
    super.dispose();
  }

  Widget _buildLandscapeLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Keeps the console close to the reference width while still allowing
        // smaller landscape screens to render safely.
        final centerConsoleWidth = constraints.maxWidth < 900
            ? 230.0
            : constraints.maxWidth < 1200
            ? 250.0
            : 270.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CounterBox(
              color: _redTeamColor,
              count: _redCount,
              onTap: _incrementRed,
              onLongPress: _decrementRed,
              teamController: _redTeamController,
              onSettingsTap: () {
                _showTeamSettings(isLeftTeam: true);
              },
              isLeftTeam: true,
              textColor: _getTextColor(_redTeamColor),
            ),

            SizedBox(
              width: centerConsoleWidth,
              child: CenterConsole(
                selectedSport: _selectedSport,
                currentSegment: _currentSegment,
                redSegmentsWon: _redSegmentsWon,
                blueSegmentsWon: _blueSegmentsWon,
                currentRedScore: _redCount,
                currentBlueScore: _blueCount,
                completedSegments: _completedSegments,
                matchComplete: _isMatchComplete,
                timerKey: _timerKey,
                onSportTap: _showSportTemplateDialog,
                onFullscreenTap: _toggleFullscreen,
                onResetTap: _resetScores,
              ),
            ),

            CounterBox(
              color: _blueTeamColor,
              count: _blueCount,
              onTap: _incrementBlue,
              onLongPress: _decrementBlue,
              teamController: _blueTeamController,
              onSettingsTap: () {
                _showTeamSettings(isLeftTeam: false);
              },
              isLeftTeam: false,
              textColor: _getTextColor(_blueTeamColor),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    return Scaffold(
      floatingActionButton: isLandscape
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'sports',
                  onPressed: _showSportTemplateDialog,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  tooltip: 'Select Sport',
                  child: const Icon(Icons.sports),
                ),

                const SizedBox(height: 12),

                FloatingActionButton.small(
                  heroTag: 'fullscreen',
                  onPressed: _toggleFullscreen,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  tooltip: 'Fullscreen',
                  child: const Icon(Icons.fullscreen),
                ),

                const SizedBox(height: 12),

                FloatingActionButton.small(
                  heroTag: 'reset',
                  onPressed: _resetScores,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  tooltip: 'Reset Scores',
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              if (orientation == Orientation.landscape) {
                return _buildLandscapeLayout();
              }

              final portraitChildren = [
                CounterBox(
                  color: _redTeamColor,
                  count: _redCount,
                  onTap: _incrementRed,
                  onLongPress: _decrementRed,
                  teamController: _redTeamController,
                  onSettingsTap: () {
                    _showTeamSettings(isLeftTeam: true);
                  },
                  isLeftTeam: true,
                  textColor: _getTextColor(_redTeamColor),
                ),
                CounterBox(
                  color: _blueTeamColor,
                  count: _blueCount,
                  onTap: _incrementBlue,
                  onLongPress: _decrementBlue,
                  teamController: _blueTeamController,
                  onSettingsTap: () {
                    _showTeamSettings(isLeftTeam: false);
                  },
                  isLeftTeam: false,
                  textColor: _getTextColor(_blueTeamColor),
                ),
              ];

              // Keep the existing portrait design unchanged.
              return Stack(
                children: [
                  Column(children: portraitChildren),

                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedSport.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedSport.segmentLabel,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              if (_selectedSport.pointsToWin > 0)
                                Text(
                                  '${_selectedSport.pointsToWin} Points • '
                                  'Win by ${_selectedSport.winBy}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              if (_selectedSport.segmentType ==
                                  MatchSegmentType.sets)
                                Text(
                                  'Sets: $_redSegmentsWon - $_blueSegmentsWon',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (_selectedSport.segmentType !=
                                  MatchSegmentType.sets)
                                Text(
                                  '${_getSegmentTitle()} $_currentSegment '
                                  'of ${_selectedSport.segmentCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        MatchTimer(key: _timerKey),
                      ],
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
