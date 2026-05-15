import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class TemaProvider extends ChangeNotifier {
  static const _boxNome = 'configuracoes';
  static const _chavetema = 'tema_escuro';

  bool _temaEscuro = false;

  bool get temaEscuro => _temaEscuro;
  ThemeMode get themeMode =>
      _temaEscuro ? ThemeMode.dark : ThemeMode.light;

  Future<void> carregar() async {
    final box = await Hive.openBox(_boxNome);
    _temaEscuro = box.get(_chavetema, defaultValue: false);
    notifyListeners();
  }

  Future<void> alternar() async {
    _temaEscuro = !_temaEscuro;
    final box = Hive.box(_boxNome);
    await box.put(_chavetema, _temaEscuro);
    notifyListeners();
  }
}