import 'dart:async';
import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Local, mock "backend" for the app.
///
/// Holds the home's state, seeded with the design's sample data, and saves the
/// parts people change (thermostat, locks, alarm, lights, scene, read events)
/// to device storage so they survive a restart. Nothing here talks to a real
/// home automation system yet; this is the seam where that would plug in.
class HomeState extends ChangeNotifier {
  HomeState(this._prefs) {
    _load();
  }

  static const _storageKey = 'home_state_v1';
  final SharedPreferences _prefs;

  // ---- Profile ----
  final String userName = 'Jaden';

  // ---- Climate ----
  static const int minTarget = 60;
  static const int maxTarget = 80;
  final int insideTemp = 72;
  final int outsideTemp = 64;
  final int humidity = 48;
  int targetTemp = 70;
  ClimateMode climateMode = ClimateMode.cool;
  bool bedtimeEnabled = true;
  final String bedtimeTime = '10:30 PM';
  final int bedtimeTarget = 68;
  final List<RoomClimate> rooms = const [
    RoomClimate('Living room', 72, 47),
    RoomClimate('Bedroom', 70, 50),
    RoomClimate('Office', 73, 45),
  ];

  // ---- Security ----
  ArmMode armMode = ArmMode.home;
  List<DoorLock> locks = const [
    DoorLock(id: 'front', name: 'Front door', lockedDetail: 'Auto-locks after 2 min', locked: true),
    DoorLock(id: 'back', name: 'Back door', lockedDetail: 'Locked at 6:12 PM', locked: true),
    DoorLock(id: 'garage', name: 'Garage', lockedDetail: 'Closed · Atlas checks at 10 PM', locked: true),
  ];
  final int windowsClosed = 14;
  final List<String> peopleHome = const ['J', 'M'];
  final int peopleAway = 1;

  // ---- Lights ----
  bool lightsOn = true;
  final int lightsOnCount = 5;
  final int lightRooms = 3;

  // ---- Scenes ----
  final List<String> scenes = const ['Morning', 'Away', 'Movie', 'Night'];
  String activeScene = 'Movie';

  // ---- Cameras ----
  final List<CameraFeed> cameras = const [
    CameraFeed(id: 'front', name: 'Front door', zone: CameraZone.outside, gradient: [Color(0xFF474C56), Color(0xFF2A2D34), Color(0xFF15171B)]),
    CameraFeed(id: 'driveway', name: 'Driveway', zone: CameraZone.outside, gradient: [Color(0xFF3A3F48), Color(0xFF1B1D22)]),
    CameraFeed(id: 'backyard', name: 'Backyard', zone: CameraZone.outside, gradient: [Color(0xFF40434B), Color(0xFF1D1F24)]),
    CameraFeed(id: 'garage', name: 'Garage', zone: CameraZone.outside, gradient: [Color(0xFF353940), Color(0xFF18191D)]),
    CameraFeed(id: 'living', name: 'Living room', zone: CameraZone.inside, gradient: [Color(0xFF353940), Color(0xFF18191D)], privacy: true),
  ];
  String featuredCameraId = 'front';
  final List<CameraEvent> events = const [
    CameraEvent(id: 'e1', title: 'Person at front door', cameraName: 'Front door', time: '7:42 PM', gradient: [Color(0xFF474C56), Color(0xFF23262C)]),
    CameraEvent(id: 'e2', title: 'Package delivered', cameraName: 'Driveway', time: '3:10 PM', gradient: [Color(0xFF3F434C), Color(0xFF202227)]),
  ];
  Set<String> readEventIds = {'e2'};

  // ---- Energy ----
  final double usingNowKw = 1.8;

  /// Electricity price per kWh. The design leaves this as "[YOUR RATE]";
  /// set it to show the monthly cost estimate.
  final double? ratePerKwh = null;
  final Map<EnergyRange, EnergySeries> energy = const {
    EnergyRange.day: EnergySeries(
      label: 'Today',
      values: [2, 2, 1, 1, 1, 2, 4, 6, 5, 3, 3, 4, 5, 4, 4, 5, 7, 9, 10, 8, 7, 6, 4, 3],
      total: '12.4',
      axis: ['12a', '6a', '12p', '6p'],
      comparison: '8% below avg',
    ),
    EnergyRange.week: EnergySeries(
      label: 'This week',
      values: [11, 14, 12, 13, 15, 18, 12],
      total: '95.2',
      axis: ['Mon', 'Wed', 'Fri', 'Sun'],
      comparison: '8% below avg',
    ),
    EnergyRange.month: EnergySeries(
      label: 'November',
      values: [12, 13, 11, 14, 12, 15, 16, 13, 12, 11, 14, 13, 12, 15, 17, 14, 12, 13, 11, 12, 14, 15, 13, 12, 13, 14, 12, 11, 13, 12],
      total: '398',
      axis: ['1', '10', '20', '30'],
      comparison: '8% below avg',
    ),
  };
  final List<DeviceUsage> topDevices = const [
    DeviceUsage('HVAC', 5.6),
    DeviceUsage('Water heater', 2.9),
    DeviceUsage('Kitchen', 1.7),
  ];

  // ---- Atlas ----
  final List<String> atlasRooms = const ['Kitchen', 'Living room'];
  final List<String> atlasSuggestions = const [
    'Who’s at the door?',
    'Set 68° at bedtime',
    'Energy this week',
  ];
  final List<ChatMessage> messages = [
    const ChatMessage(fromUser: true, text: 'Lock up and dim the living room'),
    const ChatMessage(
      fromUser: false,
      text: 'Done. Everything’s locked and the living room is set for the evening.',
      checklist: ['Front & back doors locked', 'Living room lights at 30%', 'Garage door closed'],
      actionLabel: 'Save as “Night” scene',
    ),
  ];
  bool atlasTyping = false;

  // ================= Derived values =================

  int get lockedCount => locks.where((l) => l.locked).length;
  bool get allLocked => lockedCount == locks.length;
  bool get isArmed => armMode != ArmMode.off;
  bool get allSecure => isArmed && allLocked;

  String get securitySummary {
    if (allSecure) return 'All secure';
    if (!allLocked) {
      final open = locks.length - lockedCount;
      return '$open ${open == 1 ? 'lock' : 'locks'} open';
    }
    return 'Alarm off';
  }

  String get climateModeShort => switch (climateMode) {
        ClimateMode.cool => 'Cooling',
        ClimateMode.heat => 'Heating',
        ClimateMode.auto => 'Auto',
        ClimateMode.off => 'Off',
      };

  String get climateModeLabel => switch (climateMode) {
        ClimateMode.cool => 'COOLING TO',
        ClimateMode.heat => 'HEATING TO',
        ClimateMode.auto => 'AUTO · HOLD',
        ClimateMode.off => 'SYSTEM OFF',
      };

  int get liveCameraCount => cameras.where((c) => !c.privacy).length;
  int get newEventCount => events.where((e) => !readEventIds.contains(e.id)).length;
  CameraFeed get featuredCamera => cameras.firstWhere((c) => c.id == featuredCameraId);

  // ================= Actions =================

  void setTargetTemp(int value) {
    targetTemp = value.clamp(minTarget, maxTarget);
    _changed();
  }

  void setClimateMode(ClimateMode mode) {
    climateMode = mode;
    _changed();
  }

  void toggleBedtime() {
    bedtimeEnabled = !bedtimeEnabled;
    _changed();
  }

  void setArmMode(ArmMode mode) {
    armMode = mode;
    _changed();
  }

  void toggleLock(String id) {
    locks = [for (final l in locks) l.id == id ? l.copyWith(locked: !l.locked) : l];
    _changed();
  }

  bool isLocked(String id) => locks.firstWhere((l) => l.id == id).locked;

  void toggleLights() {
    lightsOn = !lightsOn;
    _changed();
  }

  void setScene(String scene) {
    activeScene = scene;
    _changed();
  }

  void featureCamera(String id) {
    featuredCameraId = id;
    notifyListeners();
  }

  void markEventRead(String id) {
    readEventIds = {...readEventIds, id};
    _changed();
  }

  Timer? _replyTimer;

  /// Scripted assistant: echoes the message and answers with a canned reply.
  void sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    messages.add(ChatMessage(fromUser: true, text: trimmed));
    atlasTyping = true;
    notifyListeners();
    _replyTimer?.cancel();
    _replyTimer = Timer(const Duration(milliseconds: 900), () {
      atlasTyping = false;
      messages.add(const ChatMessage(
        fromUser: false,
        text: 'I’m not connected to your home yet, so I can’t act on that. '
            'Once I’m hooked up, I’ll take care of it for you.',
      ));
      notifyListeners();
    });
  }

  // ================= Persistence =================

  void _changed() {
    notifyListeners();
    _save();
  }

  void _save() {
    final data = {
      'targetTemp': targetTemp,
      'climateMode': climateMode.name,
      'bedtimeEnabled': bedtimeEnabled,
      'armMode': armMode.name,
      'locks': {for (final l in locks) l.id: l.locked},
      'lightsOn': lightsOn,
      'activeScene': activeScene,
      'readEventIds': readEventIds.toList(),
    };
    _prefs.setString(_storageKey, jsonEncode(data));
  }

  void _load() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      targetTemp = (data['targetTemp'] as int? ?? targetTemp).clamp(minTarget, maxTarget);
      climateMode = ClimateMode.values.asNameMap()[data['climateMode']] ?? climateMode;
      bedtimeEnabled = data['bedtimeEnabled'] as bool? ?? bedtimeEnabled;
      armMode = ArmMode.values.asNameMap()[data['armMode']] ?? armMode;
      final savedLocks = (data['locks'] as Map?)?.cast<String, dynamic>() ?? {};
      locks = [for (final l in locks) l.copyWith(locked: savedLocks[l.id] as bool? ?? l.locked)];
      lightsOn = data['lightsOn'] as bool? ?? lightsOn;
      final scene = data['activeScene'] as String?;
      if (scene != null && scenes.contains(scene)) activeScene = scene;
      readEventIds = {...((data['readEventIds'] as List?)?.cast<String>() ?? readEventIds)};
    } catch (_) {
      // Corrupt or outdated data: fall back to the defaults.
    }
  }

  @override
  void dispose() {
    _replyTimer?.cancel();
    super.dispose();
  }
}
