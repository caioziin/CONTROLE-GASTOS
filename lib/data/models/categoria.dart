import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'categoria.g.dart';

@HiveType(typeId: 0)
class Categoria {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nome;

  @HiveField(2)
  final int cor; // Color é salvo como int (ex: Colors.red.value)

  @HiveField(3)
  final String icone; // Nome do ícone (ex: 'restaurant')

  Categoria({
    required this.id,
    required this.nome,
    required this.cor,
    required this.icone,
  });

  // Converte o int de volta para Color
  Color get corColor => Color(cor);
}