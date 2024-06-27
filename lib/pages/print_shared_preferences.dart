import 'package:shared_preferences/shared_preferences.dart';

Future<void> printSharedPreferencesContent() async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();
  final content = <String, dynamic>{};

  for (var key in keys) {
    content[key] = prefs.get(key);
  }

  content.forEach((key, value) {
    print('$key: $value');
  });
}
