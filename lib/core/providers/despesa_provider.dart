import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/despesa.dart';
import '../../data/repositories/hive_database.dart';

class DespesaProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  List<Despesa> _despesas = [];

  List<Despesa> get despesas => _despesas;

  // ─── TOTAIS ─────────────────────────────────────────

  double get totalGasto =>
      _despesas.fold(0, (soma, d) => soma + d.valor);

  double get totalMesAtual {
    final agora = DateTime.now();
    return _despesas
        .where((d) =>
    d.data.month == agora.month && d.data.year == agora.year)
        .fold(0, (soma, d) => soma + d.valor);
  }

  List<Despesa> get despesasMesAtual {
    final agora = DateTime.now();
    return _despesas
        .where((d) =>
    d.data.month == agora.month && d.data.year == agora.year)
        .toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  List<Despesa> get ultimasDespesas {
    final lista = [..._despesas]
      ..sort((a, b) => b.data.compareTo(a.data));
    return lista.take(5).toList();
  }

  // ─── FILTROS ─────────────────────────────────────────

  List<Despesa> filtrarPorCategoria(String categoriaId) {
    return _despesas
        .where((d) => d.categoriaId == categoriaId)
        .toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  List<Despesa> filtrarPorPeriodo(DateTime inicio, DateTime fim) {
    return _despesas
        .where((d) =>
    d.data.isAfter(inicio.subtract(const Duration(days: 1))) &&
        d.data.isBefore(fim.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  List<Despesa> buscarPorTitulo(String texto) {
    return _despesas
        .where((d) =>
        d.titulo.toLowerCase().contains(texto.toLowerCase()))
        .toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  double totalPorCategoria(String categoriaId) {
    return _despesas
        .where((d) => d.categoriaId == categoriaId)
        .fold(0, (soma, d) => soma + d.valor);
  }

  // ─── CRUD ────────────────────────────────────────────

  Future<void> carregarDespesas() async {
    _despesas = HiveDatabase.getDespesas();
    notifyListeners();
  }

  Future<void> addDespesa({
    required String titulo,
    required double valor,
    required DateTime data,
    required String categoriaId,
  }) async {
    final despesa = Despesa(
      id: _uuid.v4(),
      titulo: titulo,
      valor: valor,
      data: data,
      categoriaId: categoriaId,
    );
    await HiveDatabase.addDespesa(despesa);
    _despesas.add(despesa);
    notifyListeners();
  }

  Future<void> deleteDespesa(String id) async {
    await HiveDatabase.deleteDespesa(id);
    _despesas.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  Future<void> updateDespesa(Despesa despesa) async {
    await HiveDatabase.updateDespesa(despesa);
    final index = _despesas.indexWhere((d) => d.id == despesa.id);
    if (index != -1) {
      _despesas[index] = despesa;
      notifyListeners();
    }
  }
}