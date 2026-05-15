import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/providers/categoria_provider.dart';
import '../../core/providers/despesa_provider.dart';
import '../../data/models/despesa.dart';

class GraficosScreen extends StatefulWidget {
  const GraficosScreen({super.key});

  @override
  State<GraficosScreen> createState() => _GraficosScreenState();
}

class _GraficosScreenState extends State<GraficosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      'shopping_cart': Icons.shopping_cart,
      'flight': Icons.flight,
      'pets': Icons.pets,
      'music_note': Icons.music_note,
    };
    return icones[nome] ?? Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Gráficos',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: scheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pie_chart), text: 'Pizza'),
            Tab(icon: Icon(Icons.show_chart), text: 'Evolução'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Mensal'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GraficoPizza(moeda: _moeda, iconePorNome: _iconePorNome),
          _GraficoLinha(moeda: _moeda),
          _GraficoBarras(moeda: _moeda),
        ],
      ),
    );
  }
}

// ── Gráfico de Pizza ─────────────────────────────────────────

class _GraficoPizza extends StatefulWidget {
  final NumberFormat moeda;
  final IconData Function(String) iconePorNome;

  const _GraficoPizza({required this.moeda, required this.iconePorNome});

  @override
  State<_GraficoPizza> createState() => _GraficoPizzaState();
}

class _GraficoPizzaState extends State<_GraficoPizza> {
  int _tocado = -1;

  @override
  Widget build(BuildContext context) {
    final despesaProvider = context.watch<DespesaProvider>();
    final categoriaProvider = context.watch<CategoriaProvider>();
    final despesas = despesaProvider.despesasMesAtual;
    final total = despesas.fold(0.0, (s, d) => s + d.valor);
    final scheme = Theme.of(context).colorScheme;

    // Agrupa por categoria
    final Map<String, double> porCategoria = {};
    for (final d in despesas) {
      porCategoria[d.categoriaId] =
          (porCategoria[d.categoriaId] ?? 0) + d.valor;
    }

    if (despesas.isEmpty) return _emptyState(context);

    final entradas = porCategoria.entries.toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Distribuição do mês',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          'Total: ${widget.moeda.format(total)}',
          style: TextStyle(color: scheme.outline),
        ),
        const SizedBox(height: 24),

        // Gráfico
        SizedBox(
          height: 260,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 60,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _tocado = -1;
                      return;
                    }
                    _tocado = response
                        .touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: entradas.asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value;
                final categoria =
                categoriaProvider.buscarPorId(e.key);
                final porcentagem =
                total > 0 ? (e.value / total) * 100 : 0.0;
                final isTocado = i == _tocado;

                return PieChartSectionData(
                  value: e.value,
                  color: categoria != null
                      ? Color(categoria.cor)
                      : Colors.grey,
                  title: '${porcentagem.toStringAsFixed(1)}%',
                  radius: isTocado ? 80 : 65,
                  titleStyle: TextStyle(
                    fontSize: isTocado ? 14 : 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Legenda detalhada
        ...entradas.map((e) {
          final categoria = categoriaProvider.buscarPorId(e.key);
          final porcentagem =
          total > 0 ? (e.value / total) * 100 : 0.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: categoria != null
                      ? Color(categoria.cor).withOpacity(0.2)
                      : scheme.primaryContainer,
                  child: Icon(
                    widget.iconePorNome(
                        categoria?.icone ?? 'category'),
                    color: categoria != null
                        ? Color(categoria.cor)
                        : scheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(categoria?.nome ?? 'Sem categoria',
                          style: const TextStyle(
                              fontWeight: FontWeight.w500)),
                      LinearProgressIndicator(
                        value: porcentagem / 100,
                        backgroundColor:
                        categoria != null
                            ? Color(categoria.cor).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(
                          categoria != null
                              ? Color(categoria.cor)
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(widget.moeda.format(e.value),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    Text('${porcentagem.toStringAsFixed(1)}%',
                        style: TextStyle(
                            color: scheme.outline, fontSize: 12)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ── Gráfico de Linha ─────────────────────────────────────────

class _GraficoLinha extends StatelessWidget {
  final NumberFormat moeda;
  const _GraficoLinha({required this.moeda});

  @override
  Widget build(BuildContext context) {
    final despesaProvider = context.watch<DespesaProvider>();
    final despesas = despesaProvider.despesasMesAtual;
    final scheme = Theme.of(context).colorScheme;

    if (despesas.isEmpty) return _emptyState(context);

    // Agrupa por dia do mês
    final Map<int, double> porDia = {};
    for (final d in despesas) {
      porDia[d.data.day] = (porDia[d.data.day] ?? 0) + d.valor;
    }

    // Acumulado por dia
    final dias = porDia.keys.toList()..sort();
    double acumulado = 0;
    final pontos = dias.map((dia) {
      acumulado += porDia[dia]!;
      return FlSpot(dia.toDouble(), acumulado);
    }).toList();

    final maxY = acumulado * 1.2;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Evolução de gastos',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Acumulado do mês atual',
            style: TextStyle(color: scheme.outline)),
        const SizedBox(height: 24),

        SizedBox(
          height: 280,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 4,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: scheme.outline.withOpacity(0.2),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 56,
                    getTitlesWidget: (value, meta) => Text(
                      'R\$${value.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 10, color: scheme.outline),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text(
                      'Dia ${value.toInt()}',
                      style: TextStyle(
                          fontSize: 10, color: scheme.outline),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: dias.first.toDouble(),
              maxX: dias.last.toDouble(),
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: pontos,
                  isCurved: true,
                  color: scheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                          radius: 5,
                          color: scheme.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: scheme.primary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Resumo por dia
        ...dias.map((dia) {
          final valor = porDia[dia]!;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              child: Text('$dia',
                  style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.bold)),
            ),
            title: Text('Dia $dia'),
            trailing: Text(
              moeda.format(valor),
              style: TextStyle(
                  color: scheme.error, fontWeight: FontWeight.bold),
            ),
          );
        }),
      ],
    );
  }
}

// ── Gráfico de Barras ────────────────────────────────────────

class _GraficoBarras extends StatelessWidget {
  final NumberFormat moeda;
  const _GraficoBarras({required this.moeda});

  @override
  Widget build(BuildContext context) {
    final despesaProvider = context.watch<DespesaProvider>();
    final despesas = despesaProvider.despesas;
    final scheme = Theme.of(context).colorScheme;

    if (despesas.isEmpty) return _emptyState(context);

    // Agrupa por mês
    final Map<int, double> porMes = {};
    for (final d in despesas) {
      porMes[d.data.month] = (porMes[d.data.month] ?? 0) + d.valor;
    }

    final meses = porMes.keys.toList()..sort();
    final nomeMes = [
      '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    final maxY = porMes.values.reduce((a, b) => a > b ? a : b) * 1.2;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Comparativo mensal',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Gastos por mês do ano',
            style: TextStyle(color: scheme.outline)),
        const SizedBox(height: 24),

        SizedBox(
          height: 280,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final mes = meses[groupIndex];
                    return BarTooltipItem(
                      '${nomeMes[mes]}\n',
                      const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: moeda.format(rod.toY),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final mes = meses[value.toInt()];
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(nomeMes[mes],
                            style: TextStyle(
                                fontSize: 11, color: scheme.outline)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 56,
                    getTitlesWidget: (value, meta) => Text(
                      'R\$${value.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 10, color: scheme.outline),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: scheme.outline.withOpacity(0.2),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: meses.asMap().entries.map((entry) {
                final i = entry.key;
                final mes = entry.value;
                final mesAtual = DateTime.now().month;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: porMes[mes]!,
                      color: mes == mesAtual
                          ? scheme.primary
                          : scheme.primary.withOpacity(0.4),
                      width: 22,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Tabela resumo
        ...meses.map((mes) {
          final valor = porMes[mes]!;
          final mesAtual = DateTime.now().month;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: mes == mesAtual
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (mes == mesAtual)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Atual',
                            style: TextStyle(
                                color: Colors.white, fontSize: 10)),
                      ),
                    Text(nomeMes[mes],
                        style: TextStyle(
                            fontWeight: mes == mesAtual
                                ? FontWeight.bold
                                : FontWeight.normal)),
                  ],
                ),
                Text(
                  moeda.format(valor),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: scheme.error,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ── Empty State ──────────────────────────────────────────────

Widget _emptyState(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.bar_chart,
            size: 72,
            color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 16),
        Text('Sem dados para exibir',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('Adicione despesas para ver os gráficos',
            style:
            TextStyle(color: Theme.of(context).colorScheme.outline)),
      ],
    ),
  );
}