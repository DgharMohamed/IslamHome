import 'dart:io';

void main() {
  var d = Directory(Platform.environment['LOCALAPPDATA']! + r'\Pub\Cache\hosted\pub.dev');
  var p = d.listSync().firstWhere((e) => e.path.contains('share_plus-12') || e.path.contains('share_plus-13'));
  print(p.path);
}
