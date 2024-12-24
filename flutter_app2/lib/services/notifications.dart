import 'package:awesome_notifications/awesome_notifications.dart';

class Notifications {
  static Future<void> initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'timer_notifications',
          channelKey: 'timer_notifications',
          channelName: 'Timer Finished',
          channelDescription: 'e',
          importance: NotificationImportance.High,
          playSound: true,
          soundSource: 'resource://raw/flutter_sound_effect',

          //enableVibration:
          //vibrationPattern:
          //soundSource:
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'timer_notifications_group',
          channelGroupName: 'Group 1',
        ),
      ],
      debug: true,
    );

    /* await AwesomeNotifications()
        .isNotificationAllowed()
        .then((isAllowed) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
        AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
          if (isAllowed) UserPreferences.setNotificationsOn(true);
        });
      }
    }); */

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      /* onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod, */
    );
  }

  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    //final payload = receivedAction.payload ?? {};
    /* if (payload["navigate"] == "true"){
      MyApp.navigatorKey.c
    } */
  }

  static Future<void> showNotification({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool scheduled = false,
    final int? interval,
  }) async {
    assert(!scheduled || (scheduled && interval != null));

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 0,
          channelKey: 'timer_notifications',
          title: title,
          body: body,
          actionType: actionType,
          notificationLayout: notificationLayout,
          summary: summary,
          category: category,
          payload: payload,
          bigPicture: bigPicture,
          customSound: 'resource://raw/flutter_sound_effect',
        ),
        actionButtons: actionButtons,
        schedule: scheduled
            ? NotificationInterval(
                interval: interval,
                timeZone:
                    await AwesomeNotifications().getLocalTimeZoneIdentifier(),
                preciseAlarm: true,
              )
            : null);
  }

  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancel(0);
  }
}
