class AnalyticsService {
  /// Scales the time difference between two average times to a 60-second reference.
  /// Formula: Δt60 = (AvgTimeB - AvgTimeA) * (60 / SessionAvg)
  static double calculateNormalizedDelta({
    required double avgTimeA,
    required double avgTimeB,
    required double sessionAvg,
  }) {
    if (sessionAvg == 0) return 0;
    return (avgTimeB - avgTimeA) * (60 / sessionAvg);
  }
}
