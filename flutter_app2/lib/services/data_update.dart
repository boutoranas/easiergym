import 'dart:convert';
import 'package:flutter_app/in%20app%20data.dart';
import 'package:flutter_app/services/user_preferences.dart';

class DataGestion {
  static Map? userDataMap = UserPreferences.getUserDataMap();

  static Map? profileMap = UserPreferences.getProfileMap();

  static Map? userDataMapCopy = UserPreferences.getLogInProgressMap();

  static Map? logMap;

  static DateTime? initTime = UserPreferences.getInitTime();
  static int? time;
  static DateTime? endTime = UserPreferences.getEndTime();

  static num volume = 0;

  static num sets = 0;

  static num seconds = UserPreferences.getSeconds();
  static num maxSeconds = UserPreferences.getMaxSeconds();
  static bool timerStarted = UserPreferences.getTimerStarted();
  static bool paused = UserPreferences.getTimerPaused();

  static List routinesList(userDataMap) {
    Map? routinesMap;
    if (userDataMap != null && userDataMap["routines"] != null) {
      routinesMap = userDataMap["routines"];
    } else {
      routinesMap = null;
    }

    List routinesList = [];
    if (routinesMap != null) {
      routinesMap.values.toList().forEach((element) {
        routinesList.add(element);
      });
    } else {
      routinesList = [];
    }
    return routinesList;
  }

  static List exercicesList(userDataMap, rId) {
    Map? exercicesMap;
    if (userDataMap != null &&
        userDataMap["routines"] != null &&
        userDataMap["routines"][rId] != null) {
      exercicesMap = userDataMap["routines"][rId]["exercices"];
    } else {
      exercicesMap = null;
    }

    List exercicesList;
    if (exercicesMap != null) {
      exercicesList = exercicesMap.values.toList();
    } else {
      exercicesList = [];
    }

    return exercicesList;
  }

  static List setsList(Map? userDataMap, rId, exId) {
    Map? setsMap;
    if (userDataMap!["routines"][rId]["exercices"][exId] != null) {
      setsMap = userDataMap["routines"][rId]["exercices"][exId]["sets"];
    } else {
      setsMap = null;
    }

    List setsList;
    if (setsMap != null) {
      setsList = setsMap.values.toList();
    } else {
      setsList = [];
    }

    return setsList;
  }

  static List broadExercicesList(userDataMap, rId) {
    Map? exercicesMap;
    if (userDataMap != null && userDataMap["routines"] != null) {
      exercicesMap = userDataMap["routines"][rId];
    } else {
      exercicesMap = null;
    }

    List exercicesList;
    if (exercicesMap != null || exercicesMap!["exercices"].isNotEmpty) {
      exercicesList = [];
      exercicesMap.forEach((key, value) {
        exercicesList.add({key: value});
      });
      exercicesList
          .sort((a, b) => a.keys.toString().compareTo(b.keys.toString()));
    } else {
      exercicesList = [];
    }

    return exercicesList;
  }

  static List logsList(userDataMap) {
    Map? logsMap;
    if (userDataMap != null && userDataMap["logs"] != null) {
      logsMap = userDataMap["logs"];
    } else {
      logsMap = null;
    }

    List logList;
    if (logsMap != null) {
      logList = logsMap.values.toList();
    } else {
      logList = [];
    }
    return logList;
  }

  static List exercicesInLogList(userDataMap, rId) {
    Map? exercicesMap;
    if (userDataMap != null &&
        userDataMap["logs"] != null &&
        userDataMap["logs"][rId] != null) {
      exercicesMap = userDataMap["logs"][rId]["exercices"];
    } else {
      exercicesMap = null;
    }

    List exercicesList;
    if (exercicesMap != null) {
      exercicesList = exercicesMap.values.toList();
    } else {
      exercicesList = [];
    }

    return exercicesList;
  }

  static List broadExsInLogList(userDataMap, rId) {
    Map? exercicesMap;
    if (userDataMap != null && userDataMap["logs"] != null) {
      exercicesMap = userDataMap["logs"][rId];
    } else {
      exercicesMap = null;
    }

    List exercicesList;
    if (exercicesMap != null || exercicesMap!["exercices"].isNotEmpty) {
      exercicesList = [];
      exercicesMap.forEach((key, value) {
        exercicesList.add({key: value});
      });
      exercicesList
          .sort((a, b) => a.keys.toString().compareTo(b.keys.toString()));
    } else {
      exercicesList = [];
    }

    return exercicesList;
  }

  static List setsInLogList(Map? userDataMap, rId, exId) {
    Map? setsMap;
    if (userDataMap!["logs"][rId]["exercices"][exId] != null) {
      setsMap = userDataMap["logs"][rId]["exercices"][exId]["sets"];
    } else {
      setsMap = null;
    }

    List setsList;
    if (setsMap != null) {
      setsList = setsMap.values.toList();
    } else {
      setsList = [];
    }

    return setsList;
  }

  //exercices history
  static Map exsHistory = {};

  static Map oldPrs = {};
  //Add exercices selection
  static Map selectedExercices = {};

  //explore section filtering and search
  static List isChecked1 = [];

  static List isChecked2 = [false, false, false];

  static List isChecked3 = [];

  static List isChecked4 = [];

  static List<bool> isExpanded = [false, true, false, false];

  static List selectedCategories = [];

  static List selectedDifficulties = [];

  static List selectedMuscles = [];

  static List selectedEquipment = json.decode(json.encode(InAppData.equipment));

  //exercices page search and filtering

  static List isChecked5 = [];
  static List isChecked6 = [];

  static List<bool> isExpanded1 = [true, true];

  static List selectedTypes = [];
  static List selectedCategories1 = [];

  //graphs
  static int timeSpan = 6;
  static String type = "measurements";
  static Map? mapOfData = {};
  static bool bodyParts = false;
  static String selectedBodyPart = "right arm";
  static String exercice = "Bench press (barbell)";
  static String selectedBlock = "body weight";

  //settings
  static bool weightImperial = UserPreferences.getWeightUnit() ?? false;
  static bool distanceImperial = UserPreferences.getDistanceUnit() ?? false;
  static bool sizeImperial = UserPreferences.getSizeUnit() ?? false;

  static String theme = UserPreferences.getTheme() ?? 'Default';

  static bool soundOn = UserPreferences.getSoundOn() ?? true;

  static bool notificationsOn = UserPreferences.getNotificationsOn() ?? true;
  static bool keepScreenOn = UserPreferences.getKeepScreenOn() ?? true;
}
