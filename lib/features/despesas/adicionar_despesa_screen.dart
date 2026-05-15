import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/providers/categoria_provider.dart';
import '../../core/providers/despesa_provider.dart';
import '../../data/models/categoria.dart';

class AdicionarDespesaScreen extends StatefulWidget {
  const AdicionarDespesaScreen({super.key});

  @override
  State<AdicionarDespesaScreen> createState() =>
      _AdicionarDespesaScreenState();
}

class _AdicionarDespesaScreenState extends State<AdicionarDespesaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _valorController = TextEditingController();
  DateTime _dataSelecionada = DateTime.now();
  Categoria? _categoriaSelecionada;
  bool _salvando = false;

  final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void dispose() {
    _tituloController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() => _dataSelecionada = picked);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma categoria')),
      );
      return;
    }

    setState(() => _salvando = true);

    final valor = double.tryParse(
      _valorController.text.replaceAll(',', '.'),
    ) ??
        0;

    await context.read<DespesaProvider>().addDespesa(
      titulo: _tituloController.text.trim(),
      valor: valor,
      data: _dataSelecionada,
      categoriaId: _categoriaSelecionada!.id,
    );

    setState(() => _salvando = false);
    _tituloController.clear();
    _valorController.clear();
    setState(() {
      _dataSelecionada = DateTime.now();
      _categoriaSelecionada = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Despesa adicionada com sucesso! ✅'),
          backgroundColor: Colors.green,
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final categorias = context.watch<CategoriaProvider>().categorias;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Nova Despesa',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: scheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Título ──────────────────────────────
                _label('Título'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tituloController,
                  decoration: _inputDecoration(
                      'Ex: Almoço no restaurante', Icons.edit_outlined),
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Informe o título' : null,
                ),
                const SizedBox(height: 20),

                // ── Valor ───────────────────────────────
                _label('Valor (R\$)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _valorController,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration: _inputDecoration(
                      'Ex: 45,90', Icons.attach_money),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe o valor';
                    final parsed =
                    double.tryParse(v.replaceAll(',', '.'));
                    if (parsed == null || parsed <= 0) {
                      return 'Valor inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Data ────────────────────────────────
                _label('Data'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selecionarData,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: scheme.outline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: scheme.primary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('dd/MM/yyyy')
                              .format(_dataSelecionada),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_drop_down,
                            color: scheme.outline),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Categoria ───────────────────────────
                _label('Categoria'),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: categorias.length,
                  itemBuilder: (context, index) {
                    final cat = categorias[index];
                    final selecionada =
                        _categoriaSelecionada?.id == cat.id;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _categoriaSelecionada = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: selecionada
                              ? Color(cat.cor).withOpacity(0.2)
                              : scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selecionada
                                ? Color(cat.cor)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _iconePorNome(cat.icone),
                              color: Color(cat.cor),
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cat.nome,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: selecionada
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: selecionada
                                    ? Color(cat.cor)
                                    : scheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // ── Botão salvar ────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _salvando ? null : _salvar,
                    icon: _salvando
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white),
                    )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      _salvando ? 'Salvando...' : 'Salvar Despesa',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String texto) {
    return Text(
      texto,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}