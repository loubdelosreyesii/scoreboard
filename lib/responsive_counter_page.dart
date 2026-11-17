import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import 'enums/match_segment_type.dart';
import 'models/sport_template.dart';
import 'data/sport_templates.dart';

class ResponsiveCounterPage extends StatefulWidget {
  const ResponsiveCounterPage({super.key});

  @override
  State<ResponsiveCounterPage> createState() => _ResponsiveCounterPageState();
}

class _SegmentScore {
  final int leftScore;
  final int rightScore;
  final bool leftWon;

  const _SegmentScore({
    required this.leftScore,
    required this.rightScore,
    required this.leftWon,
  });
}

class _ResponsiveCounterPageState extends State<ResponsiveCounterPage> {
  static const String _redTeamColorKey = 'red_team_color';
  static const String _blueTeamColorKey = 'blue_team_color';

  int _redCount = 0;
  int _blueCount = 0;

  int _redSegmentsWon = 0;
  int _blueSegmentsWon = 0;

  int _currentSegment = 1;
  final List<_SegmentScore> _completedSegments = [];

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
  final GlobalKey<_MatchTimerState> _timerKey = GlobalKey<_MatchTimerState>();

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
    if (_areAllSetsComplete) return;

    setState(() {
      _redCount++;
      _completeSetIfWon();
    });
  }

  void _incrementBlue() {
    if (_areAllSetsComplete) return;

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

  bool get _areAllSetsComplete =>
      _selectedSport.segmentType == MatchSegmentType.sets &&
      _selectedSport.segmentCount > 0 &&
      _completedSegments.length >= _selectedSport.segmentCount;

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
      _SegmentScore(
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
      builder: (context) {
        final teamName = isLeftTeam
            ? _redTeamController.text
            : _blueTeamController.text;

        Color pickerColor = isLeftTeam ? _redTeamColor : _blueTeamColor;

        return StatefulBuilder(
          builder: (context, setModelState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$teamName Settings',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text('Choose Team Color'),

                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _availableColors.map((color) {
                        final selectedColor = isLeftTeam
                            ? _redTeamColor
                            : _blueTeamColor;

                        final isSelected = selectedColor == color;
                        final checkColor = color.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white;

                        return InkWell(
                          onTap: () async {
                            await _updateTeamColor(
                              isLeftTeam: isLeftTeam,
                              color: color,
                            );

                            setModelState(() {});
                          },
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
                    Divider(),
                    const SizedBox(height: 16),

                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: const Text('Custom Color'),
                      subtitle: const Text('Choose any color'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text('Choose Team Color'),
                              content: StatefulBuilder(
                                builder: (context, setPickerState) {
                                  return SingleChildScrollView(
                                    child: ColorPicker(
                                      pickerColor: pickerColor,
                                      onColorChanged: (color) {
                                        setPickerState(() {
                                          pickerColor = color;
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await _updateTeamColor(
                                      isLeftTeam: isLeftTeam,
                                      color: pickerColor,
                                    );

                                    if (!dialogContext.mounted) return;

                                    setModelState(() {});
                                    Navigator.pop(dialogContext);
                                  },
                                  child: const Text('Apply'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.restart_alt),
                      title: const Text('Reset to Default'),
                      subtitle: Text(
                        isLeftTeam
                            ? 'Restore the original red color'
                            : 'Restore the original blue color',
                      ),
                      onTap: () async {
                        final defaultColor = isLeftTeam
                            ? Colors.red.shade400
                            : Colors.blue.shade400;

                        await _updateTeamColor(
                          isLeftTeam: isLeftTeam,
                          color: defaultColor,
                        );

                        setModelState(() {});
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSportTemplateDialog() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
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

                ..._sportTemplates.map(
                  (sport) => ListTile(
                    title: Text(sport.name),

                    subtitle: Text(sport.segmentLabel),

                    trailing: _selectedSport == sport
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,

                    onTap: () {
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

                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            _CounterBox(
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
              child: _CenterConsole(
                selectedSport: _selectedSport,
                currentSegment: _currentSegment,
                redSegmentsWon: _redSegmentsWon,
                blueSegmentsWon: _blueSegmentsWon,
                currentRedScore: _redCount,
                currentBlueScore: _blueCount,
                completedSegments: _completedSegments,
                allSetsComplete: _areAllSetsComplete,
                timerKey: _timerKey,
                onSportTap: _showSportTemplateDialog,
                onFullscreenTap: _toggleFullscreen,
                onResetTap: _resetScores,
              ),
            ),

            _CounterBox(
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
                _CounterBox(
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
                _CounterBox(
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
                        _MatchTimer(key: _timerKey),
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

// ---------------------------------------------------------
// Landscape Center Console
// ---------------------------------------------------------
class _CenterConsole extends StatelessWidget {
  final SportTemplate selectedSport;
  final int currentSegment;
  final int redSegmentsWon;
  final int blueSegmentsWon;
  final int currentRedScore;
  final int currentBlueScore;
  final List<_SegmentScore> completedSegments;
  final bool allSetsComplete;
  final GlobalKey<_MatchTimerState> timerKey;
  final VoidCallback onSportTap;
  final VoidCallback onFullscreenTap;
  final VoidCallback onResetTap;

  const _CenterConsole({
    required this.selectedSport,
    required this.currentSegment,
    required this.redSegmentsWon,
    required this.blueSegmentsWon,
    required this.currentRedScore,
    required this.currentBlueScore,
    required this.completedSegments,
    required this.allSetsComplete,
    required this.timerKey,
    required this.onSportTap,
    required this.onFullscreenTap,
    required this.onResetTap,
  });

  String get _segmentSingular {
    switch (selectedSport.segmentType) {
      case MatchSegmentType.sets:
        return 'Set';
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

  String get _segmentPlural {
    switch (selectedSport.segmentType) {
      case MatchSegmentType.sets:
        return 'Sets';
      case MatchSegmentType.quarters:
        return 'Quarters';
      case MatchSegmentType.periods:
        return 'Periods';
      case MatchSegmentType.halves:
        return 'Halves';
      case MatchSegmentType.none:
        return 'Segments';
    }
  }

  String get _matchFormatText {
    if (selectedSport.segmentCount <= 0) {
      return selectedSport.segmentLabel;
    }

    return 'Best of ${selectedSport.segmentCount} $_segmentPlural';
  }

  String get _rulesText {
    if (selectedSport.pointsToWin <= 0) {
      return selectedSport.segmentLabel;
    }

    return '$_matchFormatText  •  '
        'First to ${selectedSport.pointsToWin}  •  '
        'Win by ${selectedSport.winBy}';
  }

  @override
  Widget build(BuildContext context) {
    final visibleSegmentCount = selectedSport.segmentCount > 0
        ? selectedSport.segmentCount
        : 1;

    return ColoredBox(
      color: const Color(0xFF07141E),
      child: SafeArea(
        left: false,
        right: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            children: [
              _buildSportHeader(),

              const SizedBox(height: 5),

              Text(
                _rulesText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFD4DEE8),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 10),

              _buildCurrentSegmentBanner(),

              const SizedBox(height: 8),

              _buildScoreSummary(),

              const SizedBox(height: 10),

              _MatchTimer(key: timerKey, compactLandscapeDesign: true),

              const SizedBox(height: 11),

              Container(height: 1, color: const Color(0xFF47606F)),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$_segmentSingular History',
                  style: const TextStyle(
                    color: Color(0xFFE6EDF3),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Expanded(child: _buildHistoryTable(visibleSegmentCount)),

              const SizedBox(height: 10),

              _buildConsoleActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSportHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.sports_tennis, color: Colors.white, size: 23),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            selectedSport.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFF5F7FA),
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentSegmentBanner() {
    return Container(
      width: double.infinity,
      height: 29,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF192A3E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        allSetsComplete
            ? 'ALL SETS COMPLETE'
            : '${_segmentSingular.toUpperCase()} '
                  '$currentSegment OF ${selectedSport.segmentCount}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildScoreSummary() {
    return Row(
      children: [
        Expanded(
          child: _ConsoleStatCard(
            label: '$_segmentPlural Won',
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
                children: [
                  const TextSpan(
                    text: '',
                    style: TextStyle(color: Color(0xFFFF4965)),
                  ),
                  TextSpan(
                    text: '$redSegmentsWon',
                    style: const TextStyle(color: Color(0xFFFF4965)),
                  ),
                  const TextSpan(
                    text: ' - ',
                    style: TextStyle(color: Color(0xFFDDE5EC)),
                  ),
                  TextSpan(
                    text: '$blueSegmentsWon',
                    style: const TextStyle(color: Color(0xFFFF4965)),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: _ConsoleStatCard(
            label: 'Current $_segmentSingular',
            child: Text(
              '$currentRedScore - $currentBlueScore',
              style: const TextStyle(
                color: Color(0xFFF4F7FA),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConsoleActions() {
    return Container(
      height: 43,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1C27),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF1D3442), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ConsoleActionButton(
              icon: Icons.sports_rounded,
              tooltip: 'Select Sport',
              onTap: onSportTap,
            ),
          ),

          _buildActionDivider(),

          Expanded(
            child: _ConsoleActionButton(
              icon: Icons.fullscreen_rounded,
              tooltip: 'Fullscreen',
              onTap: onFullscreenTap,
            ),
          ),

          _buildActionDivider(),

          Expanded(
            child: _ConsoleActionButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Reset Scoreboard',
              onTap: onResetTap,
              foregroundColor: const Color(0xFFFF6B78),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionDivider() {
    return Container(width: 1, height: 22, color: const Color(0xFF29404E));
  }

  Widget _buildHistoryTable(int visibleSegmentCount) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1822),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1D3442), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(visibleSegmentCount, (index) {
          final segmentNumber = index + 1;
          final hasCompletedScore = index < completedSegments.length;
          final isCurrentSegment =
              segmentNumber == currentSegment && !hasCompletedScore;
          final completedScore = hasCompletedScore
              ? completedSegments[index]
              : null;

          String scoreText = '-';

          if (completedScore != null) {
            scoreText =
                '${completedScore.leftScore} - ${completedScore.rightScore}';
          } else if (isCurrentSegment) {
            scoreText = '$currentRedScore - $currentBlueScore';
          }

          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isCurrentSegment
                    ? const Color(0xFF132534)
                    : Colors.transparent,
                border: index < visibleSegmentCount - 1
                    ? const Border(
                        bottom: BorderSide(color: Color(0xFF1D3442), width: 1),
                      )
                    : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 57,
                    child: Text(
                      '$_segmentSingular $segmentNumber',
                      style: TextStyle(
                        color: const Color(0xFFE2E8EE),
                        fontSize: 10,
                        fontWeight: isCurrentSegment
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 41,
                    child: completedScore?.leftWon == true
                        ? _buildHistoryBadge('WIN', alignRight: false)
                        : null,
                  ),

                  Expanded(
                    child: Text(
                      scoreText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFF3F6F8),
                        fontSize: 11,
                        fontWeight: isCurrentSegment
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 41,
                    child: isCurrentSegment
                        ? _buildHistoryBadge('LIVE', alignRight: true)
                        : completedScore != null && !completedScore.leftWon
                        ? _buildHistoryBadge('WIN', alignRight: true)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHistoryBadge(String label, {required bool alignRight}) {
    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: label == 'LIVE'
              ? const Color(0xFF00A968)
              : const Color(0xFF1D8A5B),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _ConsoleActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color foregroundColor;

  const _ConsoleActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.foregroundColor = const Color(0xFFE6EDF3),
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 39,
            child: Center(child: Icon(icon, color: foregroundColor, size: 22)),
          ),
        ),
      ),
    );
  }
}

class _ConsoleStatCard extends StatelessWidget {
  final String label;
  final Widget child;

  const _ConsoleStatCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFF0C1C27),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFF1A3544), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFB7C4CF),
              fontSize: 9,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// Match Timer Widget
// ---------------------------------------------------------
class _MatchTimer extends StatefulWidget {
  final bool compactLandscapeDesign;

  const _MatchTimer({super.key, this.compactLandscapeDesign = false});

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
        Material(
          color: const Color(0xFF172638),
          shape: const CircleBorder(
            side: BorderSide(color: Color(0xFF2B4050), width: 1),
          ),
          child: InkWell(
            onTap: _resetTimer,
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

// ---------------------------------------------------------
// Existing Counter Box Widget
// ---------------------------------------------------------
class _CounterBox extends StatelessWidget {
  final Color color;
  final int count;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final TextEditingController teamController;
  final VoidCallback onSettingsTap;
  final bool isLeftTeam;
  final Color textColor;

  const _CounterBox({
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
