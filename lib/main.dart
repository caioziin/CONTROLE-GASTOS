import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/providers/despesa_provider.dart';
import 'core/providers/categoria_provider.dart';
import 'core/providers/tema_provider.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/hive_database.dart';
import 'shared/widgets/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
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
            create: (_) => TemaProvider()..carregar()),
        ChangeNotifierProvider(
            create: (_) => CategoriaProvider()..carregarCategorias()),
        ChangeNotifierProvider(
            create: (_) => DespesaProvider()..carregarDespesas()),
      ],
      child: Consumer<TemaProvider>(
        builder: (context, temaProvider, _) {
          return MaterialApp(
            title: 'Controle de Gastos',
            debugShowCheckedModeBanner: false,
            locale: const Locale('pt', 'BR'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('pt', 'BR'),
            ],
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: temaProvider.themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}