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
      previousAssessmentId: fields[5] as String?,
      inputHash: fields[6] as String,
      content: fields[7] as String,
      status: fields[8] as AiReportStatus,
      aiModel: fields[9] as String,
      apiParameters: (fields[10] as Map).cast<String, dynamic>(),
      generationTimeMs: fields[11] as int?,
      tags: (fields[12] as List).cast<String>(),
      userRating: fields[13] as int?,
      userFeedback: fields[14] as String?,
      summary: fields[15] as String?,
      isCached: fields[16] as bool,
      cacheExpiresAt: fields[17] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AiReport obj) {
    writer
      ..writeByte(18)
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
      ..write(obj.previousAssessmentId)
      ..writeByte(6)
      ..write(obj.inputHash)
      ..writeByte(7)
      ..write(obj.content)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.aiModel)
      ..writeByte(10)
      ..write(obj.apiParameters)
      ..writeByte(11)
      ..write(obj.generationTimeMs)
      ..writeByte(12)
      ..write(obj.tags)
      ..writeByte(13)
      ..write(obj.userRating)
      ..writeByte(14)
      ..write(obj.userFeedback)
      ..writeByte(15)
      ..write(obj.summary)
      ..writeByte(16)
      ..write(obj.isCached)
      ..writeByte(17)
      ..write(obj.cacheExpiresAt);
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
      case 3:
        return AiReportStatus.expired;
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
      case AiReportStatus.expired:
        writer.writeByte(3);
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
