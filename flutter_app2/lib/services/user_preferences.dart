import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static SharedPreferences? _preferences;

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  //!settings
  //weight unit
  static Future setWeightUnit(bool imperial) async =>
      await _preferences!.setBool('weightImperial', imperial);
  static bool? getWeightUnit() => _preferences!.getBool('weightImperial');
  //distance unit
  static Future setDistanceUnit(bool imperial) async =>
      await _preferences!.setBool('distanceUnit', imperial);
  static bool? getDistanceUnit() => _preferences!.getBool('distanceUnit');
  //size unit
  static Future setSizeUnit(bool imperial) async =>
      await _preferences!.setBool('sizeUnit', imperial);
  static bool? getSizeUnit() => _preferences!.getBool('sizeUnit');
  //theme
  static Future saveTheme(String theme) async =>
      await _preferences!.setString('theme', theme);
  static String? getTheme() => _preferences!.getString('theme');
  //sound effects
  static Future setSoundOn(bool b) async =>
      await _preferences!.setBool('soundOn', b);
  static bool? getSoundOn() => _preferences!.getBool('soundOn');
  //notifications
  static Future setNotificationsOn(bool b) async =>
      await _preferences!.setBool('notificationsOn', b);
  static bool? getNotificationsOn() => _preferences!.getBool('notificationsOn');
  //keepScreenOn
  static Future setKeepScreenOn(bool b) async =>
      await _preferences!.setBool('keepScreenOn', b);
  static bool? getKeepScreenOn() => _preferences!.getBool('keepScreenOn');

  //!userdatamap
  static Future saveUserDataMap(String encodedMap) async =>
      await _preferences!.setString('userDataMap', encodedMap);
  static Map? getUserDataMap() =>
      json.decode(_preferences!.getString('userDataMap') ?? "{}");
  static Future deleteUserDataMap() async =>
      await _preferences!.remove('userDataMap');

  static Future saveProfileMap(String encodedMap) async =>
      await _preferences!.setString('profileMap', encodedMap);
  static Map? getProfileMap() =>
      json.decode(_preferences!.getString('profileMap') ?? "{}");
  static Future deleteProfileMap() async =>
      await _preferences!.remove('profileMap');

  //!connection persistance
  static Future setConnectionState(bool connected) async =>
      await _preferences!.setBool('connected', connected);
  static bool getConnectionState() =>
      _preferences!.getBool('connected') ?? false;

  //!first time intro
  static Future setFirstTime(bool b) async =>
      await _preferences!.setBool('firstTime', b);
  static bool getFirstTime() => _preferences!.getBool('firstTime') ?? true;

  //!ensure one device is connected at a time on same account
  static Future setSessionToken(String token) async =>
      await _preferences!.setString('sessionToken', token);
  static String? getSessionToken() => _preferences!.getString('sessionToken');

  //Workout in progress
  //userdatamapcopy
  static Future saveLogInProgressMap(String encodedMap) async =>
      await _preferences!.setString('LogInProgressMap', encodedMap);
  static Map? getLogInProgressMap() =>
      json.decode(_preferences!.getString('LogInProgressMap') ?? "{}");
  static Future removeLogInProgress() async =>
      await _preferences!.remove('LogInProgressMap');

  //workoutinprogress (bool)
  static Future setWorkoutInProgress(bool workoutInProgress) async =>
      await _preferences!.setBool('workoutInProgress', workoutInProgress);
  static bool getWorkoutInProgress() =>
      _preferences!.getBool("workoutInProgress") ?? false;

  //assigned ID
  static Future saveAssignedId(String id) async =>
      await _preferences!.setString('assignedId', id);
  static String? getAssignedId() => _preferences!.getString('assignedId');
  static Future removeAssignedId() async =>
      await _preferences!.remove('assignedId');

  //save Date when exit app
  static Future saveInitTime(DateTime date) async =>
      await _preferences!.setString('initTime', date.toIso8601String());
  static DateTime? getInitTime() {
    if (_preferences!.getString('initTime') != null) {
      return DateTime.tryParse(_preferences!.getString('initTime')!);
    } else {
      return null;
    }
  }

  static Future removeInitTime() async =>
      await _preferences!.remove('initTime');

  //save end date for countdown timer
  static Future saveEndTime(DateTime date) async =>
      await _preferences!.setString('endTime', date.toIso8601String());
  static DateTime? getEndTime() {
    if (_preferences!.getString('endTime') != null) {
      return DateTime.tryParse(_preferences!.getString('endTime')!);
    } else {
      return null;
    }
  }

  static Future removeEndTime() async => await _preferences!.remove('endTime');
  //save max seconds & seconds
  static Future saveMaxSeconds(num maxSeconds) async =>
      await _preferences!.setDouble('maxSeconds', maxSeconds.toDouble());
  static num getMaxSeconds() => _preferences!.getDouble('maxSeconds') ?? 60;
  static Future removeMaxSeconds() async =>
      await _preferences!.remove('maxSeconds');

  static Future saveSeconds(num seconds) async =>
      await _preferences!.setDouble('seconds', seconds.toDouble());
  static num getSeconds() => _preferences!.getDouble('seconds') ?? 60;
  static Future removeSeconds() async => await _preferences!.remove('seconds');

  //countdown timer states
  static Future setTimerStarted(bool b) async =>
      await _preferences!.setBool('timerStarted', b);
  static bool getTimerStarted() =>
      _preferences!.getBool('timerStarted') ?? false;

  static Future setTimerPaused(bool b) async =>
      await _preferences!.setBool('timerPaused', b);
  static bool getTimerPaused() => _preferences!.getBool('timerPaused') ?? false;

  //!save profile image
  static Future setImage(String path) async =>
      await _preferences!.setString('profileimage', path);
  static String? getImage() => _preferences!.getString('profileimage');
  static Future deleteImage() async =>
      await _preferences!.remove('profileimage');
}
