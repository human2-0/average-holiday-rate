// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payslip.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PayslipAdapter extends TypeAdapter<Payslip> {
  @override
  final int typeId = 0;

  @override
  Payslip read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Payslip(
      startDate: fields[0] as DateTime,
      endDate: fields[1] as DateTime,
      hoursWorked: fields[2] as double,
      bonusesEarned: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Payslip obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.startDate)
      ..writeByte(1)
      ..write(obj.endDate)
      ..writeByte(2)
      ..write(obj.hoursWorked)
      ..writeByte(3)
      ..write(obj.bonusesEarned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayslipAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
