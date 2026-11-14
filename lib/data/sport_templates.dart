import '../models/sport_template.dart';
import '../enums/match_segment_type.dart';

const tableTennisTemplate = SportTemplate(
  name: 'Table Tennis',
  pointsToWin: 11,
  winBy: 2,
  segmentCount: 5,
  segmentType: MatchSegmentType.sets,
);

const badmintonTemplate = SportTemplate(
  name: 'Badminton',
  pointsToWin: 21,
  winBy: 2,
  segmentCount: 3,
  segmentType: MatchSegmentType.sets,
);

const volleyballTemplate = SportTemplate(
  name: 'Volleyball',
  pointsToWin: 25,
  winBy: 2,
  segmentCount: 5,
  segmentType: MatchSegmentType.sets,
);

const basketballTemplate = SportTemplate(
  name: 'Basketball',
  pointsToWin: 0,
  winBy: 0,
  segmentCount: 4,
  segmentType: MatchSegmentType.quarters,
);