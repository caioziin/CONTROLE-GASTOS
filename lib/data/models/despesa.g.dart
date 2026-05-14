// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'despesa.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DespesaAdapter extends TypeAdapter<Despesa> {
  @override
  final int typeId = 1;

  @override
  Despesa read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Despesa(
      id: fields[0] as String,
      titulo: fields[1] as String,
      valor: fields[2] as double,
      data: fields[3] as DateTime,
      categoriaId: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Despesa obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.titulo)
      ..writeByte(2)
      ..write(obj.valor)
      ..writeByte(3)
      ..write(obj.data)
      ..writeByte(4)
      ..write(obj.categoriaId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DespesaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
