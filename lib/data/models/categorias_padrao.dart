import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'categoria.dart';

const _uuid = Uuid();

final List<Categoria> categoriasPadrao = [
  Categoria(
    id: _uuid.v4(),
    nome: 'Alimentação',
    cor: Colors.orange.value,
    icone: 'restaurant',
  ),
  Categoria(
    id: _uuid.v4(),
    nome: 'Transporte',
    cor: Colors.blue.value,
    icone: 'directions_car',
  ),
  Categoria(
    id: _uuid.v4(),
    nome: 'Saúde',
    cor: Colors.red.value,
    icone: 'favorite',
  ),
  Categoria(
    id: _uuid.v4(),
    nome: 'Lazer',
    cor: Colors.purple.value,
    icone: 'sports_esports',
  ),
  Categoria(
    id: _uuid.v4(),
    nome: 'Educação',
    cor: Colors.green.value,
    icone: 'school',
  ),
  Categoria(
    id: _uuid.v4(),
    nome: 'Moradia',
    cor: Colors.brown.value,
    icone: 'home',
  ),
  Categoria(
    id: _uuid.v4(),
    nome: 'Vestuário',
    cor: Colors.pink.value,
    icone: 'checkroom',
  ),
  Categoria(
    id: _uuid.v4(),
    nome: 'Outros',
    cor: Colors.grey.value,
    icone: 'category',
  ),
];