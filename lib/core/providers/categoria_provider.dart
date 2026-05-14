import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/categoria.dart';
import '../../data/repositories/hive_database.dart';

class CategoriaProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  List<Categoria> _categorias = [];

  List<Categoria> get categorias => _categorias;

  Categoria? buscarPorId(String id) {
    try {
      return _categorias.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── CRUD ────────────────────────────────────────────

  Future<void> carregarCategorias() async {
    _categorias = HiveDatabase.getCategorias();
    notifyListeners();
  }

  Future<void> addCategoria({
    required String nome,
    required int cor,
    required String icone,
  }) async {
    final categoria = Categoria(
      id: _uuid.v4(),
      nome: nome,
      cor: cor,
      icone: icone,
    );
    await HiveDatabase.addCategoria(categoria);
    _categorias.add(categoria);
    notifyListeners();
  }

  Future<void> deleteCategoria(String id) async {
    await HiveDatabase.deleteCategoria(id);
    _categorias.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<void> updateCategoria(Categoria categoria) async {
    await HiveDatabase.updateCategoria(categoria);
    final index = _categorias.indexWhere((c) => c.id == categoria.id);
    if (index != -1) {
      _categorias[index] = categoria;
      notifyListeners();
    }
  }
}