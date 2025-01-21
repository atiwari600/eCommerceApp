import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static final FlutterLocalNotificationsPlugin _orderLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static void initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _orderLocalNotificationsPlugin.initialize(initializationSettings);

  }

  static Future<void> showCartNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Shopping Cart',
      'You have products in your cart. Place order now!',
      notificationDetails,
    );

  }

  static Future<void> showPlacedOrderNotification() async {
    const AndroidNotificationDetails orderNotificationDetails =
    AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails orderNotiDetails =
    NotificationDetails(android: orderNotificationDetails);

    await _orderLocalNotificationsPlugin.show(
      0,
      'Order Placed Successfully',
      'See order history to track status.',
      orderNotiDetails,
    );
  }
}