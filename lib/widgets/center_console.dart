import 'package:flutter/material.dart';

import '../enums/match_segment_type.dart';
import '../models/segment_score.dart';
import '../models/sport_template.dart';
import 'match_timer.dart';

class CenterConsole extends StatelessWidget {
  final SportTemplate selectedSport;
  final int currentSegment;
  final int redSegmentsWon;
  final int blueSegmentsWon;
  final int currentRedScore;
  final int currentBlueScore;
  final List<SegmentScore> completedSegments;
  final bool matchComplete;
  final GlobalKey<MatchTimerState> timerKey;
  final VoidCallback onSportTap;
  final VoidCallback onFullscreenTap;
  final VoidCallback onResetTap;

  const CenterConsole({
    super.key,
    required this.selectedSport,
    required this.currentSegment,
    required this.redSegmentsWon,
    required this.blueSegmentsWon,
    required this.currentRedScore,
    required this.currentBlueScore,
    required this.completedSegments,
    required this.matchComplete,
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

              MatchTimer(
                key: timerKey,
                compactLandscapeDesign: true,
                onResetTap: onResetTap,
              ),

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
        matchComplete
            ? 'MATCH COMPLETE'
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

        //const SizedBox(width: 9),

        // Expanded(
        //   child: _ConsoleStatCard(
        //     label: 'Current $_segmentSingular',
        //     child: Text(
        //       '$currentRedScore - $currentBlueScore',
        //       style: const TextStyle(
        //         color: Color(0xFFF4F7FA),
        //         fontSize: 20,
        //         fontWeight: FontWeight.w800,
        //       ),
        //     ),
        //   ),
        // ),
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
              segmentNumber == currentSegment &&
              !hasCompletedScore &&
              !matchComplete;
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

  const _ConsoleActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
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
            child: Center(
              child: Icon(icon, color: const Color(0xFFE6EDF3), size: 22),
            ),
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
