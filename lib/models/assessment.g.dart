// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssessmentAdapter extends TypeAdapter<Assessment> {
  @override
  final int typeId = 0;

  @override
  Assessment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Assessment(
      id: fields[0] as String,
      createdAt: fields[1] as DateTime,
      type: fields[2] as AssessmentType,
      scores: (fields[3] as Map).cast<String, double>(),
      notes: (fields[4] as Map).cast<String, String>(),
      overallNote: fields[5] as String?,
      aiAnalysisContent: fields[6] as String?,
      aiAnalysisGeneratedAt: fields[7] as DateTime?,
      aiAnalysisSummary: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Assessment obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.scores)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.overallNote)
      ..writeByte(6)
      ..write(obj.aiAnalysisContent)
      ..writeByte(7)
      ..write(obj.aiAnalysisGeneratedAt)
      ..writeByte(8)
      ..write(obj.aiAnalysisSummary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssessmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AssessmentTypeAdapter extends TypeAdapter<AssessmentType> {
  @override
  final int typeId = 1;

  @override
  AssessmentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AssessmentType.deep;
      case 1:
        return AssessmentType.quick;
      default:
        return AssessmentType.deep;
    }
  }

  @override
  void write(BinaryWriter writer, AssessmentType obj) {
    switch (obj) {
      case AssessmentType.deep:
        writer.writeByte(0);
        break;
      case AssessmentType.quick:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssessmentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
