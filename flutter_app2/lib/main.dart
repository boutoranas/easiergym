import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/auth/firebase_auth_methods.dart';
import 'package:flutter_app/screens/authentification%20screens/verify_email_page.dart';
import 'package:flutter_app/screens/authentification%20screens/welcome_page.dart';
import 'package:flutter_app/services/data_update.dart';
import 'package:flutter_app/services/notifications.dart';
import 'package:flutter_app/services/user_preferences.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'package:wakelock/wakelock.dart';
import 'theme/theme.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

final uid = FirebaseAuth.instance.currentUser != null
    ? FirebaseAuth.instance.currentUser!.uid
    : null;

void main() async {
  print("starting...");
  WidgetsFlutterBinding.ensureInitialized();
  await UserPreferences.init();
  await Notifications.initializeNotifications();
  await Firebase.initializeApp();
  //FirebaseDatabase.instance.setPersistenceEnabled(true);
  imageCache.clear();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    if (UserPreferences.getFirstTime() == true) {
      Wakelock.enable();
    } else {
      bool enabled = DataGestion.keepScreenOn;
      enabled == true ? Wakelock.enable() : Wakelock.disable();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //load images
    precacheImage(
        const AssetImage(
            'assets/images/Authentification_screen_decoration1.png'),
        context);
    precacheImage(
        const AssetImage(
            'assets/images/Authentification_screen_decoration2.png'),
        context);
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, child) {
        final provider = Provider.of<ThemeProvider>(context);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Easier gym',
          themeMode: provider.theme,
          theme: lightTheme(),
          darkTheme: darkTheme(),
          navigatorObservers: [routeObserver],
          home: const LandingPage(),
        );
      },
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  bool dataLoaded = false;

  /* @override
  void didChangeDependencies() {
    AppMediaQuerry.setMq(context);
    super.didChangeDependencies();
  } */

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      body: UpgradeAlert(
        upgrader: Upgrader(
            //debugDisplayOnce: true,
            ),
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return VerifyEmailPage(
                contxt: context,
              );
            } else {
              return const WelcomePage();
            }
            //return ForgotPassword();
          },
        ),
      ),
    );
  }
}
