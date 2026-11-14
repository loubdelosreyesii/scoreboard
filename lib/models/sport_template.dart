import '../enums/match_segment_type.dart';

class SportTemplate {
  final String name;
  final int pointsToWin;
  final int winBy;
  final int segmentCount;
  final MatchSegmentType segmentType;

  const SportTemplate({
    required this.name,
    required this.pointsToWin,
    required this.winBy,
    required this.segmentCount,
    required this.segmentType,
  });

  String get segmentLabel {
    switch (segmentType) {
      case MatchSegmentType.sets:
        return 'Best of $segmentCount Sets';

      case MatchSegmentType.quarters:
        return '$segmentCount Quarters';

      case MatchSegmentType.periods:
        return '$segmentCount Periods';

      case MatchSegmentType.halves:
        return '$segmentCount Halves';

      case MatchSegmentType.none:
        return 'No Match Segments';
    }
  }
}
