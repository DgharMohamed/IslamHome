import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:adhan/adhan.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/core/utils/scaffold_utils.dart';
import 'package:islam_home/presentation/widgets/qibla_painters.dart';
import 'package:islam_home/presentation/providers/location_provider.dart';
import 'package:islam_home/data/services/al_adhan_service.dart';
import 'package:islam_home/core/utils/magnetic_declination.dart';
import 'package:islam_home/core/utils/compass_filter.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  bool _hasPermissions = false;
  double? _apiQiblaDirection;
  bool _isLoadingApi = false;
  String? _lastCoordinates;
  bool _isRequesting = false;

  // ── Accuracy fixes ──
  final CompassFilter _compassFilter = CompassFilter(smoothingFactor: 0.2);
  double _magneticDeclination = 0.0;
  bool _showCalibrationHint = true;
  double? _compassAccuracy;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    // Auto-dismiss calibration hint after 8 seconds
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) setState(() => _showCalibrationHint = false);
    });
  }

  Future<void> _checkPermissions() async {
    if (_isRequesting) return;
    setState(() => _isRequesting = true);
    try {
      final status = await Permission.locationWhenInUse.request();
      if (status.isGranted) {
        if (mounted) {
          setState(() {
            _hasPermissions = true;
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  Future<void> _fetchApiQibla(double lat, double lng) async {
    final coordKey = '$lat,$lng';
    if (_lastCoordinates == coordKey) return;

    setState(() {
      _isLoadingApi = true;
      _lastCoordinates = coordKey;
    });

    // Calculate magnetic declination for this location
    try {
      final geoField = GeomagneticField.calculate(
        latitudeDeg: lat,
        longitudeDeg: lng,
      );
      _magneticDeclination = geoField.declination;
      debugPrint(
          'QiblaScreen: Magnetic declination at ($lat, $lng) = ${_magneticDeclination.toStringAsFixed(2)}°');
    } catch (e) {
      debugPrint('QiblaScreen: Declination calculation failed: $e');
      _magneticDeclination = 0.0;
    }

    final direction =
        await ref.read(alAdhanServiceProvider).getQiblaDirection(lat, lng);

    if (mounted) {
      setState(() {
        _apiQiblaDirection = direction;
        _isLoadingApi = false;
      });
    }
  }

  /// Converts magnetic heading to true heading using declination.
  double _toTrueHeading(double magneticHeading) {
    return normalizeAngle(magneticHeading + _magneticDeclination);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locationState = ref.watch(locationProvider);

    // Parse coordinates from locationProvider
    double lat = 0;
    double lng = 0;
    if (locationState.gpsCoordinates != null) {
      final parts = locationState.gpsCoordinates!.split(',');
      if (parts.length == 2) {
        lat = double.tryParse(parts[0]) ?? 0;
        lng = double.tryParse(parts[1]) ?? 0;

        // Trigger API fetch when coordinates change
        if (!_isLoadingApi &&
            (_apiQiblaDirection == null ||
                _lastCoordinates != locationState.gpsCoordinates)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fetchApiQibla(lat, lng);
          });
        }
      }
    }

    if (!_hasPermissions) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(
            l10n.qibla,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded, size: 28),
            onPressed: () => GlobalScaffoldService.openDrawer(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_off_rounded,
                size: 80,
                color: Colors.white24,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.locationPermissionRequired,
                style: GoogleFonts.cairo(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkPermissions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.black,
                ),
                child: Text(l10n.grantPermission),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D47A1), AppTheme.backgroundColor],
            stops: [0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Custom Header
              _buildHeader(l10n),

              // 2. Calibration Hint Banner
              if (_showCalibrationHint) _buildCalibrationHint(l10n),

              Expanded(
                child: Platform.isWindows
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.compass_calibration,
                                size: 80, color: Colors.white54),
                            const SizedBox(height: 16),
                            Text(
                              l10n.qiblaNotSupportedOnWindows,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.qiblaWindowsHint,
                              style: GoogleFonts.cairo(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : StreamBuilder<CompassEvent>(
                        stream: FlutterCompass.events,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child:
                                  Text(l10n.error(snapshot.error.toString())),
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primaryColor,
                              ),
                            );
                          }

                          final double? rawHeading = snapshot.data?.heading;
                          if (rawHeading == null) {
                            return Center(child: Text(l10n.noSensors));
                          }

                          // Track compass accuracy
                          _compassAccuracy = snapshot.data?.accuracy;

                          // ── FIX 1: Smooth the compass reading ──
                          final smoothedMagnetic =
                              _compassFilter.update(rawHeading);

                          // ── FIX 2: Convert magnetic heading → true heading ──
                          final trueHeading =
                              _toTrueHeading(smoothedMagnetic);

                          // Calculate Qibla bearing (from True North)
                          double qiblaDirection;
                          bool isUsingApi = false;

                          if (_apiQiblaDirection != null) {
                            qiblaDirection = _apiQiblaDirection!;
                            isUsingApi = true;
                          } else {
                            final qibla = Qibla(Coordinates(lat, lng));
                            qiblaDirection = qibla.direction;
                          }

                          // Distance to Kaaba
                          final double distanceInMeters =
                              Geolocator.distanceBetween(
                            lat,
                            lng,
                            21.4225,
                            39.8262,
                          );

                          // Check if needle is pointing near Qibla (within 3°)
                          final angleDiff =
                              angularDifference(trueHeading, qiblaDirection)
                                  .abs();
                          final isAligned = angleDiff < 3.0;

                          return Column(
                            children: [
                              const Spacer(),
                              // 3. Accuracy indicator
                              if (_showCalibrationHint) _buildCalibrationHint(l10n),
                              if (_compassAccuracy != null &&
                                  _compassAccuracy! < 0)
                                _buildLowAccuracyWarning(l10n),
                              // 4. Compass Section (now using true heading)
                              _buildCompass(
                                  trueHeading, qiblaDirection, isAligned),
                              const Spacer(),
                              // 5. Info Badges
                              _buildInfoBadges(
                                l10n,
                                qiblaDirection,
                                distanceInMeters,
                                lat,
                                lng,
                                trueHeading: trueHeading,
                                isUsingApi: isUsingApi,
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          Text(
            l10n.qibla,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
            onPressed: () => GlobalScaffoldService.openDrawer(),
          ),
        ],
      ),
    );
  }

  /// Calibration hint banner shown at startup.
  Widget _buildCalibrationHint(AppLocalizations l10n) {
    return AnimatedOpacity(
      opacity: _showCalibrationHint ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.amber, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.calibrateCompass,
                    style: GoogleFonts.cairo(
                      color: Colors.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (Platform.isWindows) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.qiblaWindowsHint,
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _showCalibrationHint = false),
              child: const Icon(Icons.close, color: Colors.amber, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  /// Warning shown when compass accuracy is poor.
  Widget _buildLowAccuracyWarning(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber, color: Colors.redAccent, size: 16),
            const SizedBox(width: 6),
            Text(
              l10n.compassLowAccuracy,
              style: GoogleFonts.cairo(
                color: Colors.redAccent,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass(
      double trueHeading, double qiblaDirection, bool isAligned) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Top Ornament
        Positioned(
          top: -40,
          child: CustomPaint(
            size: const Size(120, 60),
            painter: QiblaOrnamentPainter(color: Colors.white24),
          ),
        ),

        // Rotating Dial - rotates opposite to true heading
        Transform.rotate(
          angle: (trueHeading * -1) * (math.pi / 180),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(320, 320),
                painter: QiblaDialPainter(color: Colors.white24),
              ),
            ],
          ),
        ),

        // Fixed Center components (Needle) - points to Qibla
        Transform.rotate(
          angle: (qiblaDirection - trueHeading) * (math.pi / 180),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(40, 260),
                painter: CompassNeedlePainter(),
              ),
            ],
          ),
        ),

        // Alignment glow effect when pointing at Qibla
        if (isAligned)
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),

        // Center Point
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isAligned ? Colors.green : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryColor, width: 4),
            boxShadow: [
              BoxShadow(
                color: (isAligned ? Colors.green : AppTheme.primaryColor)
                    .withValues(alpha: 0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBadges(
    AppLocalizations l10n,
    double qiblaDirection,
    double distance,
    double lat,
    double lng, {
    double trueHeading = 0,
    bool isUsingApi = false,
  }) {
    return Column(
      children: [
        // DataSource Badge + Declination info
        if (_isLoadingApi)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryColor,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              isUsingApi
                  ? l10n.qiblaSourceApi(_magneticDeclination.toStringAsFixed(1))
                  : l10n.qiblaSourceOffline(_magneticDeclination.toStringAsFixed(1)),
              style: GoogleFonts.cairo(fontSize: 10, color: Colors.white38),
            ),
          ),

        // Coordinates Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '${lat >= 0 ? 'N' : 'S'}  ${lat.abs().toStringAsFixed(2)}°  ${lng >= 0 ? 'E' : 'W'}  ${lng.abs().toStringAsFixed(2)}°',
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Distance & Angle Badges
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInfoCard(
              '${(distance / 1000).toStringAsFixed(0)} KM',
              l10n.distanceFromKabah,
              const Icon(Icons.mosque, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 12),
            _buildInfoCard(
              '${qiblaDirection.toStringAsFixed(1)}°',
              l10n.qiblaDirectionLabel,
              const Icon(Icons.architecture, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 12),
            _buildSmallRoundBadge('${trueHeading.toStringAsFixed(0)}°'),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String value, String label, Widget icon) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: Colors.black54,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallRoundBadge(String label) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
