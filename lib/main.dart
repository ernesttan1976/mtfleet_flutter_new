import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/navigations/approvingOfficerNavigation.dart';
import 'package:transport_flutter/navigations/driverNavigation.dart';
import 'package:transport_flutter/navigations/macNavigation.dart';
import 'package:transport_flutter/screens/ApprovingOfficer/DestinationApproval.dart';
import 'package:transport_flutter/screens/ApprovingOfficer/MTRACApprovalTwo.dart';
import 'package:transport_flutter/screens/Driver/adHocDestinationForm.dart';
import 'package:transport_flutter/screens/Driver/additionalDetail.dart';
import 'package:transport_flutter/screens/Driver/elogBook.dart';
import 'package:transport_flutter/screens/Driver/elogBookForm.dart';
import 'package:transport_flutter/screens/Driver/frontPassenger.dart';
import 'package:transport_flutter/screens/Driver/mt_broad_cast/page.dart';
import 'package:transport_flutter/screens/Driver/past_14_days_elog/page.dart';
import 'package:transport_flutter/screens/Driver/quiz.dart';
import 'package:transport_flutter/screens/Driver/riskAccessment.dart';
import 'package:transport_flutter/screens/Driver/trip.dart';
import 'package:transport_flutter/screens/Driver/tripForm.dart';
import 'package:transport_flutter/screens/MAC/CheckInForm.dart';
import 'package:transport_flutter/screens/MAC/Maintenance.dart';
import 'package:transport_flutter/screens/MAC/VehicleUpdate.dart';
import 'package:transport_flutter/screens/MAC/ViewLog.dart';
import 'package:transport_flutter/screens/appLoading.dart';
import 'package:transport_flutter/screens/login.dart';
import 'package:transport_flutter/screens/loginWebView.dart';
import 'package:transport_flutter/screens/video.dart';
import 'package:transport_flutter/theme/theme.dart';

import 'screens/ApprovingOfficer/trip_approval_one.dart';

// ATTENTION: Change the DSN below with your own to see the events in Sentry. Get one at sentry.io
const String dsn =
    'https://5cd614d50f114e0397e96ca1751b8149@o563140.ingest.sentry.io/5703226';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  logger.e('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.high,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

final navigatorKey = GlobalKey<NavigatorState>();
final logger = Logger();
String? selectedNotificationPayload;

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  HttpOverrides.global = MyHttpOverrides();
  await SentryFlutter.init(
    (options) {
      options.dsn = dsn;
      // use breadcrumb tracking of WidgetsBindingObserver
      // options.useFlutterBreadcrumbTracking();
      // use breadcrumb tracking of platform Sentry SDKs
      options.useNativeBreadcrumbTracking();
    },
    // Init your App.
    appRunner: () => runApp(const MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    _setupNotificationListeners();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [
          SentryNavigatorObserver(),
        ],
        title: 'RSAF Transport',
        debugShowCheckedModeBanner: false,
        initialRoute: '/appLoading',
        routes: {
          '/appLoading': (context) => AppLoadingScreen(),
          '/login': (context) => LoginScreen(),
          '/loginWebView': (context) => LoginAuthScreen(),
          '/video': (context) => VideoScreen(),
          '/driver': (context) => DriverNavigation(),
          //'/learning': (context) => LearningVideoScreen(),
          '/driver/trips': (context) => TripScreen(),
          '/driver/mtbroadcast': (context) => MTBroadCast(),
          '/driver/tripform': (context) => TripFormScreen(true, false),
          '/driver/additionaldetails': (context) => AdditionalDetailScreen(),
          '/driver/riskaccessment': (context) => RiskAccessmentScreen(),
          '/driver/frontpassenger': (context) => FrontPassengerScreen(),
          '/driver/elogbook': (context) => ElogBookScreen(),
          '/driver/elogbookform': (context) => ELogBookFormScreen(),
          '/driver/adhocdestinationform': (context) =>
              AdHocDestinationFormScreen(),
          '/driver/quiz': (context) => QuizScreen(),
          '/driver/past14DaysELog': (context) => Past14DaysELog(),
          '/approvingOfficer': (context) => ApprovingOfficerNavigation(),
          '/approvingOfficer/destinationapproval': (context) =>
              DestinationApprovalScreen(),
          '/approvingOfficer/mtrcapprovaltwo': (context) =>
              MTRACApprovalSecondScreen(),
          '/approvingOfficer/tripapproval': (context) => TripApprovalScreen(),
          '/mac': (context) => MACNavigation(),
          '/mac/checkinform': (context) => CheckInFormScreen(),
          '/mac/maintenance': (context) => MaintenanceScreen(),
          '/mac/viewlog': (context) => const ViewLogScreen(servicingId: 0),
          '/mac/vehicleupdateform': (context) => const VehicleUpdateScreen(
                servicingID: 0,
                currentUpdates: null,
              ),
        },
        theme: AppTheme.themeData);
  }

  void _setupNotificationListeners() async {
    flutterLocalNotificationsPlugin ??= FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final List<DarwinNotificationCategory> darwinNotificationCategories =
        <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        darwinNotificationCategoryText,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.text(
            'text_1',
            'Action 1',
            buttonTitle: 'Send',
            placeholder: 'Placeholder',
          ),
        ],
      ),
      DarwinNotificationCategory(
        darwinNotificationCategoryPlain,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain('id_1', 'Action 1'),
          DarwinNotificationAction.plain(
            'id_2',
            'Action 2 (destructive)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.destructive,
            },
          ),
          DarwinNotificationAction.plain(
            navigationActionId,
            'Action 3 (foreground)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
          DarwinNotificationAction.plain(
            'id_4',
            'Action 4 (auth required)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.authenticationRequired,
            },
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      )
    ];

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: darwinNotificationCategories,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: initializationSettingsDarwin,
    );

    String? token = await messaging.getToken();

    logger.e("Firebase Token $token");
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(
      _handleNotifies,
      onError: (error, trace) {
        logger.e("onMessage Listen Error $error $trace");
      },
      onDone: () {
        logger.e("onMessage Listen Done");
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotifiesClicked);

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      logger.e(
          "Firebase Message Called ${message?.data} ${message?.notification?.body}");
      if (message != null && message.notification != null) {
        logger.e(message.notification);
        Future.delayed(const Duration(seconds: 2), () {
          final tripId = message.data['tripId'];
          navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (_) => TripApprovalScreen(
              tripID: tripId,
            ),
          ));
        });
      }
    });

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: false,
    );
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      showAlertDialog(
        context,
        "Notification Permission",
        "You need to give permission for notification! otherwise you won't be able to get notification.",
      );
    }
  }

  void _handleNotifies(RemoteMessage? message) {
    RemoteNotification? notification = message?.notification;
    AndroidNotification? android = message?.notification?.android;
    logger.e("HandleNotifies ${message?.data} ${message?.notification} ");
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin?.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails()),
      );
    }
  }

  void _handleNotifiesClicked(RemoteMessage? message) {
    if (message != null) {
      final tripId = message.data['tripId'];
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (_) => TripApprovalScreen(
          tripID: tripId,
        ),
      ));
    }
  }
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}
