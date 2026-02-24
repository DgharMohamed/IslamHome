import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final alAdhanServiceProvider = Provider((ref) => AlAdhanService());

class AlAdhanService {
  final Dio _dio = Dio();

  /// Fetches Qibla direction for coordinates.
  /// API: https://api.aladhan.com/v1/qibla/:latitude/:longitude
  Future<double?> getQiblaDirection(double lat, double lng) async {
    try {
      final url = 'https://api.aladhan.com/v1/qibla/$lat/$lng';
      debugPrint('AlAdhanService: Fetching Qibla from $url');

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final direction = response.data['data']['direction'];
        if (direction is num) {
          return direction.toDouble();
        }
      } else {
        debugPrint('AlAdhanService Error: ${response.data['status']}');
      }
    } catch (e) {
      debugPrint('AlAdhanService Critical Error: $e');
    }
    return null;
  }
}
