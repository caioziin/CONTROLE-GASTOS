import 'package:hive_flutter/hive_flutter.dart';
import '../models/categoria.dart';
import '../models/despesa.dart';
import '../models/categorias_padrao.dart';

class HiveDatabase {
  static const String _boxDespesas = 'despesas';
  static const String _boxCategorias = 'categorias';

  // Inicializa o Hive e registra os adapters
  static Future<void> init() async {
    await Hive.initFlutter();

    // Registra os adapters gerados pelo build_runner
    Hive.registerAdapter(CategoriaAdapter());
    Hive.registerAdapter(DespesaAdapter());

    // Abre as caixas (tabelas)
    await Hive.openBox<Categoria>(_boxCategorias);
    await Hive.openBox<Despesa>(_boxDespesas);

    // Insere categorias padrão se ainda não existirem
    final boxCategorias = Hive.box<Categoria>(_boxCategorias);
    if (boxCategorias.isEmpty) {
      for (final categoria in categoriasPadrao) {
        await boxCategorias.put(categoria.id, categoria);
      }
    }
  }

  // ─── DESPESAS ───────────────────────────────────────

  static Box<Despesa> get _despesasBox => Hive.box<Despesa>(_boxDespesas);

  static List<Despesa> getDespesas() => _despesasBox.values.toList();

  static Future<void> addDespesa(Despesa despesa) async {
    await _despesasBox.put(despesa.id, despesa);
  }

  static Future<void> deleteDespesa(String id) async {
    await _despesasBox.delete(id);
  }

  static Future<void> updateDespesa(Despesa despesa) async {
    await _despesasBox.put(despesa.id, despesa);
  }

  // ─── CATEGORIAS ─────────────────────────────────────

  static Box<Categoria> get _categoriasBox =>
      Hive.box<Categoria>(_boxCategorias);

  static List<Categoria> getCategorias() => _categoriasBox.values.toList();

  static Future<void> addCategoria(Categoria categoria) async {
    await _categoriasBox.put(categoria.id, categoria);
  }

  static Future<void> deleteCategoria(String id) async {
    await _categoriasBox.delete(id);
  }

  static Future<void> updateCategoria(Categoria categoria) async {
    await _categoriasBox.put(categoria.id, categoria);
  }
}