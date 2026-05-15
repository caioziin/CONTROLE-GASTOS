import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/providers/categoria_provider.dart';
import '../../core/providers/despesa_provider.dart';
import '../../core/providers/tema_provider.dart'; // ← ADICIONADO: import do TemaProvider
import '../../data/models/despesa.dart';
import 'graficos_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _filtroPeriodo = 'mês';
  final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  List<Despesa> _despesasFiltradas(DespesaProvider provider) {
    final agora = DateTime.now();
    DateTime inicio;
    switch (_filtroPeriodo) {
      case 'semana':
        inicio = agora.subtract(const Duration(days: 7));
        break;
      case 'ano':
        inicio = DateTime(agora.year, 1, 1);
        break;
      default:
        inicio = DateTime(agora.year, agora.month, 1);
    }
    return provider.filtrarPorPeriodo(inicio, agora);
  }

  @override
  Widget build(BuildContext context) {
    final despesaProvider = context.watch<DespesaProvider>();
    final categoriaProvider = context.watch<CategoriaProvider>();
    final despesas = _despesasFiltradas(despesaProvider);
    final total = despesas.fold(0.0, (s, d) => s + d.valor);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Olá! 👋',
                style: Theme.of(context).textTheme.titleSmall),
            Text('Controle de Gastos',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          // ← ADICIONADO: botão de alternar tema claro/escuro
          Consumer<TemaProvider>(
            builder: (context, temaProvider, _) => IconButton(
              icon: Icon(
                temaProvider.temaEscuro
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              tooltip: 'Alternar tema',
              onPressed: temaProvider.alternar,
            ),
          ),
          // ← FIM DA ADIÇÃO
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Ver gráficos',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const GraficosScreen()),
            ),
          ),
          CircleAvatar(
            backgroundColor: scheme.primaryContainer,
            child: Icon(Icons.person, color: scheme.primary),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await despesaProvider.carregarDespesas();
            await categoriaProvider.carregarCategorias();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Filtro de período ───────────────────────
              Row(
                children: ['semana', 'mês', 'ano'].map((periodo) {
                  final selecionado = _filtroPeriodo == periodo;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(periodo[0].toUpperCase() +
                          periodo.substring(1)),
                      selected: selecionado,
                      onSelected: (_) =>
                          setState(() => _filtroPeriodo = periodo),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // ── Card de resumo ──────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scheme.primary, scheme.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total gasto — $_filtroPeriodo',
                      style: TextStyle(
                          color: scheme.onPrimary.withOpacity(0.8),
                          fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _moeda.format(total),
                      style: TextStyle(
                        color: scheme.onPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _infoChip(context, Icons.receipt_long,
                            '${despesas.length} despesas'),
                        const SizedBox(width: 12),
                        _infoChip(
                            context,
                            Icons.calendar_today,
                            _filtroPeriodo[0].toUpperCase() +
                                _filtroPeriodo.substring(1)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Botão atalho gráficos ───────────────────
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const GraficosScreen()),
                ),
                icon: const Icon(Icons.bar_chart),
                label: const Text('Ver relatórios e gráficos'),
              ),
              const SizedBox(height: 24),

              // ── Gráfico de pizza ────────────────────────
              if (despesas.isNotEmpty) ...[
                Text('Por categoria',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: _gerarSecoes(
                                despesas, categoriaProvider, total),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _gerarLegenda(
                            despesas, categoriaProvider, total, context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Últimas despesas ────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Últimas despesas',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text('${despesas.length} registros',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.outline)),
                ],
              ),
              const SizedBox(height: 12),

              if (despesas.isEmpty)
                _emptyState(context)
              else
                ...despesas.take(5).map((despesa) {
                  final categoria =
                  categoriaProvider.buscarPorId(despesa.categoriaId);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: categoria != null
                            ? Color(categoria.cor).withOpacity(0.2)
                            : scheme.primaryContainer,
                        child: Icon(
                          _iconePorNome(categoria?.icone ?? 'category'),
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
                            color: scheme.outline, fontSize: 12),
                      ),
                      trailing: Text(
                        _moeda.format(despesa.valor),
                        style: TextStyle(
                          color: scheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(BuildContext context, IconData icon, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.onPrimary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: scheme.onPrimary),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(color: scheme.onPrimary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text('Nenhuma despesa ainda',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Toque em Adicionar para registrar',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.outline)),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _gerarSecoes(
      List<Despesa> despesas,
      CategoriaProvider categoriaProvider,
      double total,
      ) {
    final Map<String, double> porCategoria = {};
    for (final d in despesas) {
      porCategoria[d.categoriaId] =
          (porCategoria[d.categoriaId] ?? 0) + d.valor;
    }
    return porCategoria.entries.map((entry) {
      final categoria = categoriaProvider.buscarPorId(entry.key);
      final porcentagem = total > 0 ? (entry.value / total) * 100 : 0.0;
      return PieChartSectionData(
        value: entry.value,
        color: categoria != null ? Color(categoria.cor) : Colors.grey,
        title: '${porcentagem.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white),
      );
    }).toList();
  }

  List<Widget> _gerarLegenda(
      List<Despesa> despesas,
      CategoriaProvider categoriaProvider,
      double total,
      BuildContext context,
      ) {
    final Map<String, double> porCategoria = {};
    for (final d in despesas) {
      porCategoria[d.categoriaId] =
          (porCategoria[d.categoriaId] ?? 0) + d.valor;
    }
    return porCategoria.entries.take(4).map((entry) {
      final categoria = categoriaProvider.buscarPorId(entry.key);
      final porcentagem = total > 0 ? (entry.value / total) * 100 : 0.0;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: categoria != null
                    ? Color(categoria.cor)
                    : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${categoria?.nome ?? 'Outros'} ${porcentagem.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      );
    }).toList();
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
}