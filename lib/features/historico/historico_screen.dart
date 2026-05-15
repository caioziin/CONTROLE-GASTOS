import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/providers/categoria_provider.dart';
import '../../core/providers/despesa_provider.dart';
import '../../data/models/despesa.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  final _buscaController = TextEditingController();
  String _textoBusca = '';
  String? _categoriaFiltro;
  final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  IconData _iconePorNome(String nome) {
    const icones = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'favorite': Icons.favorite,
      'sports_esports': Icons.sports_esports,
      'school': Icons.school,
      'home': Icons.home,
      'checkroom': Icons.checkroom,
      'category': Icons.category,
    };
    return icones[nome] ?? Icons.category;
  }

  Map<String, List<Despesa>> _agruparPorMes(List<Despesa> despesas) {
    final Map<String, List<Despesa>> agrupado = {};
    for (final d in despesas) {
      final chave = DateFormat('MMMM yyyy', 'pt_BR').format(d.data);
      agrupado.putIfAbsent(chave, () => []).add(d);
    }
    return agrupado;
  }

  @override
  Widget build(BuildContext context) {
    final despesaProvider = context.watch<DespesaProvider>();
    final categoriaProvider = context.watch<CategoriaProvider>();
    final scheme = Theme.of(context).colorScheme;

    // Aplica filtros
    List<Despesa> despesas = despesaProvider.despesas
      ..sort((a, b) => b.data.compareTo(a.data));

    if (_textoBusca.isNotEmpty) {
      despesas = despesaProvider.buscarPorTitulo(_textoBusca);
    }
    if (_categoriaFiltro != null) {
      despesas =
          despesas.where((d) => d.categoriaId == _categoriaFiltro).toList();
    }

    final agrupado = _agruparPorMes(despesas);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Histórico',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: scheme.surface,
        elevation: 0,
        actions: [
          if (_categoriaFiltro != null || _textoBusca.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              tooltip: 'Limpar filtros',
              onPressed: () {
                setState(() {
                  _categoriaFiltro = null;
                  _textoBusca = '';
                  _buscaController.clear();
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Busca ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _buscaController,
              onChanged: (v) => setState(() => _textoBusca = v),
              decoration: InputDecoration(
                hintText: 'Buscar despesa...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _textoBusca.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _buscaController.clear();
                    setState(() => _textoBusca = '');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // ── Filtro por categoria ─────────────────────
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Todas'),
                    selected: _categoriaFiltro == null,
                    onSelected: (_) =>
                        setState(() => _categoriaFiltro = null),
                  ),
                ),
                ...categoriaProvider.categorias.map((cat) {
                  final selecionada = _categoriaFiltro == cat.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(
                        _iconePorNome(cat.icone),
                        size: 16,
                        color: Color(cat.cor),
                      ),
                      label: Text(cat.nome),
                      selected: selecionada,
                      onSelected: (_) => setState(() =>
                      _categoriaFiltro = selecionada ? null : cat.id),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Lista agrupada ───────────────────────────
          Expanded(
            child: despesas.isEmpty
                ? _emptyState(context)
                : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: agrupado.entries.map((entry) {
                final totalMes = entry.value
                    .fold(0.0, (s, d) => s + d.valor);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabeçalho do mês
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key[0].toUpperCase() +
                                entry.key.substring(1),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scheme.primary),
                          ),
                          Text(
                            _moeda.format(totalMes),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: scheme.error,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Despesas do mês
                    ...entry.value.map((despesa) {
                      final categoria = categoriaProvider
                          .buscarPorId(despesa.categoriaId);
                      return Dismissible(
                        key: Key(despesa.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding:
                          const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: scheme.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete,
                              color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          return await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Excluir despesa'),
                              content: Text(
                                  'Deseja excluir "${despesa.titulo}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Excluir'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) {
                          despesaProvider
                              .deleteDespesa(despesa.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '"${despesa.titulo}" excluída'),
                              backgroundColor: scheme.error,
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: categoria != null
                                  ? Color(categoria.cor)
                                  .withOpacity(0.2)
                                  : scheme.primaryContainer,
                              child: Icon(
                                _iconePorNome(
                                    categoria?.icone ?? 'category'),
                                color: categoria != null
                                    ? Color(categoria.cor)
                                    : scheme.primary,
                              ),
                            ),
                            title: Text(despesa.titulo,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            subtitle: Text(
                              '${categoria?.nome ?? 'Sem categoria'} • ${DateFormat('dd/MM/yyyy').format(despesa.data)}',
                              style: TextStyle(
                                  color: scheme.outline,
                                  fontSize: 12),
                            ),
                            trailing: Text(
                              _moeda.format(despesa.valor),
                              style: TextStyle(
                                color: scheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const Divider(),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history,
              size: 72,
              color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text('Nenhuma despesa encontrada',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Tente outro filtro ou adicione uma despesa',
            style: TextStyle(
                color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
    );
  }
}