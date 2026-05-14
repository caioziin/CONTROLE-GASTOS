import 'package:hive/hive.dart';

part 'despesa.g.dart';

@HiveType(typeId: 1)
class Despesa {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String titulo;

  @HiveField(2)
  final double valor;

  @HiveField(3)
  final DateTime data;

  @HiveField(4)
  final String categoriaId; // Referência à Categoria pelo id

  Despesa({
    required this.id,
    required this.titulo,
    required this.valor,
    required this.data,
    required this.categoriaId,
  });
}