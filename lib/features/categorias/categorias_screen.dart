import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/providers/categoria_provider.dart';
import '../../core/providers/despesa_provider.dart';
import '../../data/models/categoria.dart';

class CategoriasScreen extends StatelessWidget {
  const CategoriasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoriaProvider = context.watch<CategoriaProvider>();
    final despesaProvider = context.watch<DespesaProvider>();
    final scheme = Theme.of(context).colorScheme;
    final moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final categorias = categoriaProvider.categorias;
    final totalGeral = despesaProvider.totalMesAtual;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Categorias',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: scheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nova categoria',
            onPressed: () => _modalCategoria(context),
          ),
        ],
      ),
      body: categorias.isEmpty
          ? _emptyState(context)
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final cat = categorias[index];
          final totalCat =
          despesaProvider.totalPorCategoria(cat.id);
          final porcentagem =
          totalGeral > 0 ? totalCat / totalGeral : 0.0;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Ícone
                      CircleAvatar(
                        backgroundColor:
                        Color(cat.cor).withOpacity(0.15),
                        child: Icon(
                          _iconePorNome(cat.icone),
                          color: Color(cat.cor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Nome e total
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(cat.nome,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            Text(
                              '${(porcentagem * 100).toStringAsFixed(0)}% do mês',
                              style: TextStyle(
                                  color: scheme.outline,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // Valor
                      Text(
                        moeda.format(totalCat),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: scheme.error,
                          fontSize: 15,
                        ),
                      ),
                      // Ações
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'editar',
                            child: Row(children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ]),
                          ),
                          const PopupMenuItem(
                            value: 'excluir',
                            child: Row(children: [
                              Icon(Icons.delete,
                                  size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Excluir',
                                  style:
                                  TextStyle(color: Colors.red)),
                            ]),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'editar') {
                            _modalCategoria(context,
                                categoria: cat);
                          } else {
                            _confirmarExclusao(
                                context, cat, categoriaProvider);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Barra de progresso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: porcentagem,
                      minHeight: 8,
                      backgroundColor:
                      Color(cat.cor).withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color(cat.cor)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _modalCategoria(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova Categoria'),
      ),
    );
  }

  // ── Modal criar/editar categoria ──────────────────────

  void _modalCategoria(BuildContext context, {Categoria? categoria}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ModalCategoria(categoria: categoria),
    );
  }

  void _confirmarExclusao(
      BuildContext context,
      Categoria cat,
      CategoriaProvider provider,
      ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir categoria'),
        content: Text('Deseja excluir "${cat.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.deleteCategoria(cat.id);
              Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
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

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text('Nenhuma categoria',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Toque em + para criar uma',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.outline)),
        ],
      ),
    );
  }
}

// ── Modal de criação/edição ───────────────────────────────

class _ModalCategoria extends StatefulWidget {
  final Categoria? categoria;
  const _ModalCategoria({this.categoria});

  @override
  State<_ModalCategoria> createState() => _ModalCategoriaState();
}

class _ModalCategoriaState extends State<_ModalCategoria> {
  final _nomeController = TextEditingController();
  int _corSelecionada = Colors.blue.value;
  String _iconeSelecionado = 'category';

  final List<int> _cores = [
    Colors.red.value,
    Colors.orange.value,
    Colors.amber.value,
    Colors.green.value,
    Colors.teal.value,
    Colors.blue.value,
    Colors.indigo.value,
    Colors.purple.value,
    Colors.pink.value,
    Colors.brown.value,
    Colors.grey.value,
    Colors.cyan.value,
  ];

  final Map<String, IconData> _icones = {
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'favorite': Icons.favorite,
    'sports_esports': Icons.sports_esports,
    'school': Icons.school,
    'home': Icons.home,
    'checkroom': Icons.checkroom,
    'category': Icons.category,
    'shopping_cart': Icons.shopping_cart,
    'flight': Icons.flight,
    'pets': Icons.pets,
    'music_note': Icons.music_note,
  };

  @override
  void initState() {
    super.initState();
    if (widget.categoria != null) {
      _nomeController.text = widget.categoria!.nome;
      _corSelecionada = widget.categoria!.cor;
      _iconeSelecionado = widget.categoria!.icone;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_nomeController.text.isEmpty) return;
    final provider = context.read<CategoriaProvider>();

    if (widget.categoria != null) {
      await provider.updateCategoria(Categoria(
        id: widget.categoria!.id,
        nome: _nomeController.text.trim(),
        cor: _corSelecionada,
        icone: _iconeSelecionado,
      ));
    } else {
      await provider.addCategoria(
        nome: _nomeController.text.trim(),
        cor: _corSelecionada,
        icone: _iconeSelecionado,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.categoria != null
                ? 'Editar Categoria'
                : 'Nova Categoria',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Nome
          TextField(
            controller: _nomeController,
            decoration: InputDecoration(
              labelText: 'Nome da categoria',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          // Cores
          const Text('Cor',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _cores.map((cor) {
              final selecionada = _corSelecionada == cor;
              return GestureDetector(
                onTap: () => setState(() => _corSelecionada = cor),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(cor),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selecionada ? scheme.onSurface : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: selecionada
                      ? const Icon(Icons.check,
                      color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Ícones
          const Text('Ícone',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _icones.entries.map((entry) {
              final selecionado = _iconeSelecionado == entry.key;
              return GestureDetector(
                onTap: () =>
                    setState(() => _iconeSelecionado = entry.key),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selecionado
                        ? Color(_corSelecionada).withOpacity(0.2)
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selecionado
                          ? Color(_corSelecionada)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(entry.value,
                      color: selecionado
                          ? Color(_corSelecionada)
                          : scheme.onSurface),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Botão salvar
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _salvar,
              child: Text(widget.categoria != null
                  ? 'Salvar alterações'
                  : 'Criar categoria'),
            ),
          ),
        ],
      ),
    );
  }
}