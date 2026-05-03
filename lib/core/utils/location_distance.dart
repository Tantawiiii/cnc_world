import 'dart:math' as math;

/// Great-circle distance between two WGS84 points (kilometers).
double haversineDistanceKm(
  double lat1Deg,
  double lon1Deg,
  double lat2Deg,
  double lon2Deg,
) {
  const earthKm = 6371.0;
  final p1 = lat1Deg * math.pi / 180.0;
  final p2 = lat2Deg * math.pi / 180.0;
  final dLat = (lat2Deg - lat1Deg) * math.pi / 180.0;
  final dLon = (lon2Deg - lon1Deg) * math.pi / 180.0;

  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(p1) *
          math.cos(p2) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthKm * c;
}
