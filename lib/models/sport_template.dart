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

  SportTemplate copyWith({int? segmentCount}) {
    return SportTemplate(
      name: name,
      pointsToWin: pointsToWin,
      winBy: winBy,
      segmentCount: segmentCount ?? this.segmentCount,
      segmentType: segmentType,
    );
  }

  String get segmentLabel {
    switch (segmentType) {
      case MatchSegmentType.sets:
        final setLabel = segmentCount == 1 ? 'Set' : 'Sets';
        return 'Best of $segmentCount $setLabel';

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
