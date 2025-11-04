// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AiReportAdapter extends TypeAdapter<AiReport> {
  @override
  final int typeId = 3;

  @override
  AiReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AiReport(
      id: fields[0] as String,
      createdAt: fields[1] as DateTime,
      updatedAt: fields[2] as DateTime,
      version: fields[3] as int,
      assessmentId: fields[4] as String,
      inputHash: fields[5] as String,
      content: fields[6] as String?,
      status: fields[7] as AiReportStatus,
      error: fields[8] as String?,
      aiModel: fields[9] as String,
      generationTimeMs: fields[11] as int?,
      apiParameters: (fields[10] as Map).cast<String, dynamic>(),
      tags: (fields[12] as List).cast<String>(),
      isCached: fields[13] as bool,
      cachedAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AiReport obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.updatedAt)
      ..writeByte(3)
      ..write(obj.version)
      ..writeByte(4)
      ..write(obj.assessmentId)
      ..writeByte(5)
      ..write(obj.inputHash)
      ..writeByte(6)
      ..write(obj.content)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.error)
      ..writeByte(9)
      ..write(obj.aiModel)
      ..writeByte(10)
      ..write(obj.apiParameters)
      ..writeByte(11)
      ..write(obj.generationTimeMs)
      ..writeByte(12)
      ..write(obj.tags)
      ..writeByte(13)
      ..write(obj.isCached)
      ..writeByte(14)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AiReportStatusAdapter extends TypeAdapter<AiReportStatus> {
  @override
  final int typeId = 4;

  @override
  AiReportStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AiReportStatus.generating;
      case 1:
        return AiReportStatus.completed;
      case 2:
        return AiReportStatus.failed;
      default:
        return AiReportStatus.generating;
    }
  }

  @override
  void write(BinaryWriter writer, AiReportStatus obj) {
    switch (obj) {
      case AiReportStatus.generating:
        writer.writeByte(0);
        break;
      case AiReportStatus.completed:
        writer.writeByte(1);
        break;
      case AiReportStatus.failed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiReportStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
