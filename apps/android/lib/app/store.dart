import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Dónde se guarda el estado. En la app, `shared_preferences`; en las pruebas, memoria.
abstract interface class Store {
  Future<Map<String, Object?>?> load();
  Future<void> save(Map<String, Object?> data);
  Future<void> clear();
}

class PrefsStore implements Store {
  PrefsStore() : _prefs = SharedPreferencesAsync();
  static const _key = 'calc-bateria-v1';
  final SharedPreferencesAsync _prefs;

  @override
  Future<Map<String, Object?>?> load() async {
    try {
      final s = await _prefs.getString(_key);
      return s == null ? null : (jsonDecode(s) as Map).cast<String, Object?>();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(Map<String, Object?> data) => _prefs.setString(_key, jsonEncode(data));

  @override
  Future<void> clear() => _prefs.remove(_key);
}

class MemoryStore implements Store {
  MemoryStore([this.data]);
  Map<String, Object?>? data;
  @override
  Future<Map<String, Object?>?> load() async => data == null ? null : Map.of(data!);
  @override
  Future<void> save(Map<String, Object?> d) async => data = Map.of(d);
  @override
  Future<void> clear() async => data = null;
}
