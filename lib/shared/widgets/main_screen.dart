import 'package:flutter/material.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/despesas/adicionar_despesa_screen.dart';
import '../../features/historico/historico_screen.dart';
import '../../features/categorias/categorias_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _indiceSelecionado = 0;

  final List<Widget> _telas = [
    const DashboardScreen(),
    const AdicionarDespesaScreen(),
    const HistoricoScreen(),
    const CategoriasScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _telas[_indiceSelecionado],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceSelecionado,
        onDestinationSelected: (indice) {
          setState(() => _indiceSelecionado = indice);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Adicionar',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Histórico',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Categorias',
          ),
        ],
      ),
    );
  }
}