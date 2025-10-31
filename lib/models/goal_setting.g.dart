// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_setting.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalSettingAdapter extends TypeAdapter<GoalSetting> {
  @override
  final int typeId = 2;

  @override
  GoalSetting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalSetting(
      abilityId: fields[0] as String,
      scoreDescriptions: (fields[1] as Map).cast<int, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, GoalSetting obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.abilityId)
      ..writeByte(1)
      ..write(obj.scoreDescriptions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalSettingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
