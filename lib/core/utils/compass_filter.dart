import 'dart:math' as math;

/// A low-pass filter for compass headings that correctly handles
/// the 0°/360° boundary (circular averaging).
class CompassFilter {
  final double _smoothingFactor;
  double? _filteredSin;
  double? _filteredCos;

  /// [smoothingFactor] controls the responsiveness (0.0 = very smooth, 1.0 = no filter).
  /// Recommended: 0.15 - 0.25 for a good balance of stability and responsiveness.
  CompassFilter({double smoothingFactor = 0.2})
    : _smoothingFactor = smoothingFactor.clamp(0.01, 1.0);

  /// Updates the filter with a new heading reading (in degrees, 0-360).
  /// Returns the smoothed heading in degrees (0-360).
  double update(double headingDeg) {
    final rad = headingDeg * math.pi / 180.0;
    final s = math.sin(rad);
    final c = math.cos(rad);

    if (_filteredSin == null || _filteredCos == null) {
      _filteredSin = s;
      _filteredCos = c;
    } else {
      _filteredSin =
          _filteredSin! * (1 - _smoothingFactor) + s * _smoothingFactor;
      _filteredCos =
          _filteredCos! * (1 - _smoothingFactor) + c * _smoothingFactor;
    }

    var result = math.atan2(_filteredSin!, _filteredCos!) * 180.0 / math.pi;
    if (result < 0) result += 360.0;
    return result;
  }

  /// Resets the filter state.
  void reset() {
    _filteredSin = null;
    _filteredCos = null;
  }
}

/// Normalizes an angle to the range [0, 360).
double normalizeAngle(double degrees) {
  var result = degrees % 360.0;
  if (result < 0) result += 360.0;
  return result;
}

/// Calculates the shortest angular difference between two angles in degrees.
/// Result is in range [-180, 180].
double angularDifference(double from, double to) {
  var diff = (to - from) % 360.0;
  if (diff > 180) diff -= 360;
  if (diff < -180) diff += 360;
  return diff;
}
