import 'dart:math' as math;

/// Calculates magnetic declination using a simplified World Magnetic Model.
/// Uses WMM2020 coefficients with secular variation for extrapolation.
/// Accuracy: ~1-2° for most populated areas worldwide.
class GeomagneticField {
  /// Magnetic declination in degrees (positive = East, negative = West).
  final double declination;

  GeomagneticField._(this.declination);

  /// WMM2020 Gauss coefficients [n, m, gnm, hnm, gDot, hDot]
  /// gnm/hnm in nT, gDot/hDot in nT/year
  static const List<List<double>> _wmm2020 = [
    // n, m,      g,       h,    gDot,  hDot
    [1, 0, -29404.5, 0.0, 6.7, 0.0],
    [1, 1, -1450.7, 4652.9, 7.7, -25.1],
    [2, 0, -2500.0, 0.0, -11.5, 0.0],
    [2, 1, 2982.0, -2991.6, -7.1, -30.2],
    [2, 2, 1676.8, -734.8, -2.2, -23.9],
    [3, 0, 1363.9, 0.0, 2.8, 0.0],
    [3, 1, -2381.0, -82.2, -6.2, 5.7],
    [3, 2, 1236.2, 241.8, 3.4, -1.0],
    [3, 3, 525.7, -542.9, -12.2, 1.1],
    [4, 0, 903.1, 0.0, -1.1, 0.0],
    [4, 1, 809.4, 282.0, -1.6, 6.9],
    [4, 2, 86.2, -158.4, -6.0, 2.5],
    [4, 3, -309.4, 199.8, 5.4, 3.7],
    [4, 4, 47.9, -350.1, -5.5, -5.6],
    [5, 0, -234.4, 0.0, -0.3, 0.0],
    [5, 1, 363.1, 47.7, 0.1, 0.4],
    [5, 2, 187.8, 208.4, -0.7, 2.5],
    [5, 3, -140.7, -121.3, 0.1, -0.9],
    [5, 4, -151.2, 32.2, 1.2, 3.0],
    [5, 5, 13.7, 99.1, 1.0, 0.5],
  ];

  /// Calculate magnetic declination at the given location.
  ///
  /// [latitudeDeg] Geographic latitude in degrees (-90 to 90)
  /// [longitudeDeg] Geographic longitude in degrees (-180 to 180)
  /// [altitudeKm] Altitude above sea level in km (default 0)
  /// [date] Date for calculation (default: now)
  factory GeomagneticField.calculate({
    required double latitudeDeg,
    required double longitudeDeg,
    double altitudeKm = 0,
    DateTime? date,
  }) {
    final now = date ?? DateTime.now();
    final yearFraction =
        now.year + (now.month - 1) / 12.0 + (now.day - 1) / 365.25;
    // Years since WMM2020 epoch
    final dt = yearFraction - 2020.0;

    // Clamp dt to reasonable range (WMM valid for ~5 years)
    final dtClamped = dt.clamp(-5.0, 10.0);

    const double earthRadius = 6371.2; // km
    final r = earthRadius + altitudeKm;

    final latRad = latitudeDeg * math.pi / 180.0;
    final lonRad = longitudeDeg * math.pi / 180.0;

    // Colatitude (from north pole)
    final theta = math.pi / 2.0 - latRad;
    final cosTheta = math.cos(theta);
    final sinTheta = math.sin(theta);

    // Compute Schmidt semi-normalized associated Legendre polynomials
    const maxN = 5;
    final p = List.generate(
      maxN + 2,
      (i) => List.filled(maxN + 2, 0.0),
    ); // P[n][m]
    final dp = List.generate(
      maxN + 2,
      (i) => List.filled(maxN + 2, 0.0),
    ); // dP/dTheta

    p[0][0] = 1.0;
    dp[0][0] = 0.0;
    p[1][0] = cosTheta;
    dp[1][0] = -sinTheta;
    p[1][1] = sinTheta;
    dp[1][1] = cosTheta;

    for (int n = 2; n <= maxN; n++) {
      // Diagonal term P[n][n]
      p[n][n] = sinTheta * math.sqrt((2 * n - 1) / (2.0 * n)) * p[n - 1][n - 1];
      dp[n][n] =
          math.sqrt((2 * n - 1) / (2.0 * n)) *
          (cosTheta * p[n - 1][n - 1] + sinTheta * dp[n - 1][n - 1]);

      // Sub-diagonal P[n][n-1]
      p[n][n - 1] = cosTheta * math.sqrt(2.0 * n - 1) * p[n - 1][n - 1];
      dp[n][n - 1] =
          math.sqrt(2.0 * n - 1) *
          (-sinTheta * p[n - 1][n - 1] + cosTheta * dp[n - 1][n - 1]);

      // Other terms
      for (int m = 0; m <= n - 2; m++) {
        final double nn = n.toDouble();
        final double mm = m.toDouble();
        final k1 = (2 * nn - 1) / math.sqrt(nn * nn - mm * mm);
        final k2 = math.sqrt(
          ((nn - 1) * (nn - 1) - mm * mm) / (nn * nn - mm * mm),
        );

        p[n][m] = k1 * cosTheta * p[n - 1][m] - k2 * p[n - 2][m];
        dp[n][m] =
            k1 * (-sinTheta * p[n - 1][m] + cosTheta * dp[n - 1][m]) -
            k2 * dp[n - 2][m];
      }
    }

    // Compute field components (X=North, Y=East, Z=Down)
    double bx = 0, by = 0;

    for (final coeff in _wmm2020) {
      final n = coeff[0].toInt();
      final m = coeff[1].toInt();
      final g = coeff[2] + coeff[4] * dtClamped;
      final h = coeff[3] + coeff[5] * dtClamped;

      final rRatio = math.pow(earthRadius / r, n + 2);

      // X component (north) = -dV/dTheta
      bx +=
          rRatio *
          (g * math.cos(m * lonRad) + h * math.sin(m * lonRad)) *
          dp[n][m];

      // Y component (east) = dV/(sinTheta * dPhi)
      if (sinTheta.abs() > 1e-10) {
        by +=
            rRatio *
            m *
            (-g * math.sin(m * lonRad) + h * math.cos(m * lonRad)) *
            p[n][m] /
            sinTheta;
      }
    }

    // by as accumulated is -Y (east), so negate it.
    // bx as accumulated is already X (north), no negation needed.
    by = -by;

    // Declination = atan2(Y, X)
    final declination = math.atan2(by, bx) * 180.0 / math.pi;

    return GeomagneticField._(declination);
  }
}
