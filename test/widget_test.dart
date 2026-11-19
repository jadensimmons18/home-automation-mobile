import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_automation/state/home_state.dart';
import 'package:home_automation/state/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('HomeState', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('starts with the design sample data', () {
      final home = HomeState(prefs);
      expect(home.targetTemp, 70);
      expect(home.climateMode, ClimateMode.cool);
      expect(home.armMode, ArmMode.home);
      expect(home.allSecure, isTrue);
      expect(home.newEventCount, 1);
      expect(home.activeScene, 'Movie');
    });

    test('clamps the thermostat target to 60–80', () {
      final home = HomeState(prefs);
      home.setTargetTemp(95);
      expect(home.targetTemp, 80);
      home.setTargetTemp(10);
      expect(home.targetTemp, 60);
    });

    test('unlocking a door makes the home not secure', () {
      final home = HomeState(prefs);
      home.toggleLock('front');
      expect(home.allSecure, isFalse);
      expect(home.securitySummary, '1 lock open');
    });

    test('changes persist across restarts', () {
      final first = HomeState(prefs)
        ..setTargetTemp(74)
        ..setClimateMode(ClimateMode.heat)
        ..setArmMode(ArmMode.away)
        ..toggleLock('garage')
        ..toggleLights()
        ..setScene('Night')
        ..markEventRead('e1');
      first.dispose();

      final second = HomeState(prefs);
      expect(second.targetTemp, 74);
      expect(second.climateMode, ClimateMode.heat);
      expect(second.armMode, ArmMode.away);
      expect(second.isLocked('garage'), isFalse);
      expect(second.lightsOn, isFalse);
      expect(second.activeScene, 'Night');
      expect(second.newEventCount, 0);
    });
  });
}
