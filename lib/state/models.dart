import 'package:material_ui/material_ui.dart';

enum ClimateMode { cool, heat, auto, off }

enum ArmMode { off, home, away }

enum CameraZone { outside, inside }

enum EnergyRange { day, week, month }

class DoorLock {
  const DoorLock({
    required this.id,
    required this.name,
    required this.lockedDetail,
    required this.locked,
  });

  final String id;
  final String name;
  final String lockedDetail;
  final bool locked;

  DoorLock copyWith({bool? locked}) => DoorLock(
        id: id,
        name: name,
        lockedDetail: lockedDetail,
        locked: locked ?? this.locked,
      );
}

class RoomClimate {
  const RoomClimate(this.name, this.temp, this.humidity);
  final String name;
  final int temp;
  final int humidity;
}

class CameraFeed {
  const CameraFeed({
    required this.id,
    required this.name,
    required this.zone,
    required this.gradient,
    this.privacy = false,
  });

  final String id;
  final String name;
  final CameraZone zone;
  final List<Color> gradient;

  /// Privacy mode: the camera is off and shows no feed.
  final bool privacy;
}

class CameraEvent {
  const CameraEvent({
    required this.id,
    required this.title,
    required this.cameraName,
    required this.time,
    required this.gradient,
  });

  final String id;
  final String title;
  final String cameraName;
  final String time;
  final List<Color> gradient;
}

class EnergySeries {
  const EnergySeries({
    required this.label,
    required this.values,
    required this.total,
    required this.axis,
    required this.comparison,
  });

  final String label;
  final List<double> values;
  final String total;
  final List<String> axis;
  final String comparison;
}

class DeviceUsage {
  const DeviceUsage(this.name, this.kwh);
  final String name;
  final double kwh;
}

class ChatMessage {
  const ChatMessage({
    required this.fromUser,
    required this.text,
    this.checklist = const [],
    this.actionLabel,
  });

  final bool fromUser;
  final String text;
  final List<String> checklist;
  final String? actionLabel;
}
