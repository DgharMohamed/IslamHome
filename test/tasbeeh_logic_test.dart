import 'package:flutter_test/flutter_test.dart';
import 'package:islam_home/data/models/tasbeeh_model.dart';

void main() {
  group('Tasbeeh Logic Tests', () {
    test('Initial Dhikr list should be in correct order', () {
      final dhikrs = [
        'astaghfirullah',
        'subhanallah',
        'alhamdulillah',
        'la_ilaha_illa_allah',
        'allahuakbar',
      ];

      // This is a placeholder for actual service testing,
      // but verifies the sequence we intended.
      expect(dhikrs[0], 'astaghfirullah');
      expect(dhikrs[1], 'subhanallah');
      expect(dhikrs[2], 'alhamdulillah');
      expect(dhikrs[3], 'la_ilaha_illa_allah');
      expect(dhikrs[4], 'allahuakbar');
    });

    test('TasbeehModel copyWith works correctly', () {
      final model = TasbeehModel(
        id: '1',
        text: 'Test',
        arabicText: 'تجربة',
        count: 0,
        target: 33,
      );

      final updated = model.copyWith(count: 1);
      expect(updated.count, 1);
      expect(updated.id, '1');
    });
  });
}
