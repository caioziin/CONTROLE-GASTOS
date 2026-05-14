import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/despesa_provider.dart';
import 'core/providers/categoria_provider.dart';
import 'data/repositories/hive_database.dart';
import 'shared/widgets/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => CategoriaProvider()..carregarCategorias()),
        ChangeNotifierProvider(
            create: (_) => DespesaProvider()..carregarDespesas()),
      ],
      child: MaterialApp(
        title: 'Controle de Gastos',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}