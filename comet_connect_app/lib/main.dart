import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_or_signup.dart';
import 'pages/homepage.dart';
import 'pages/groups_page.dart';
import 'pages/selectdate.dart';

// Define your API endpoint URLs
const String loginUrl = 'http://192.168.1.229:3000/api/login';
const String dataUrl = 'http://192.168.1.229:3000/api/data'; // MongoDB database
//const String createUrl = 'http://localhost:3000/api/create';
//const String updateUrl = 'http://localhost:3000/api/update';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final routerDelegate = MyRouterDelegate();
  final routeInformationParser = MyRouteInformationParser();

  autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? loggedIn = prefs.getBool('loggedin');

    if (loggedIn == true) {
      return const MyHomePage();
    } else {
      return const LoginOrSignup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Comet Connect App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerDelegate: routerDelegate,
      routeInformationParser: routeInformationParser,
    );
  }
}

class MyRouterDelegate extends RouterDelegate<MyRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<MyRoutePath> {
  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  List<Page> _pages = [
    const MaterialPage(
      key: ValueKey('LoginOrSignup'),
      child: LoginOrSignup(),
    ),
    const MaterialPage(
      key: ValueKey('home'),
      child: MyHomePage(),
    ),
    const MaterialPage(
      key: ValueKey('groups'),
      child: MyHomePage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: List.of(_pages),
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        _pages.removeLast();
        notifyListeners();

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(MyRoutePath path) async {
    if (path.isLoginPage) {
      _pages = [
        const MaterialPage(
          key: ValueKey('LoginOrSignup'),
          child: LoginOrSignup(),
        ),
      ];
    } else if (path.isHomePage) {
      _pages.add(
        const MaterialPage(
          key: ValueKey('home'),
          child: MyHomePage(),
        ),
      );
    } else if (path.isCalendarPage) {
      _pages.add(
        const MaterialPage(
          key: ValueKey('CalendarPage'),
          child: SelectDate(),
        ),
      );
    } else if (path.isGroupsPage) {
      _pages.add(
        const MaterialPage(
          key: ValueKey('GroupsPage'),
          child: GroupsPage(),
        ),
      );
      // } else if (path.isHelpPage) {
      //   _pages.add(
      //     MaterialPage(
      //       key: const ValueKey('HelpPage'),
      //       child: HelpPage(),
      //     ),
      //   );
    }
    notifyListeners();
  }
}

class MyRouteInformationParser extends RouteInformationParser<MyRoutePath> {
  @override
  Future<MyRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);

    if (uri.pathSegments.isEmpty) {
      return MyRoutePath.login();
    } else if (uri.pathSegments.length == 1 && uri.pathSegments[0] == 'home') {
      return MyRoutePath.home();
    } else if (uri.pathSegments.length == 1 &&
        uri.pathSegments[0] == 'calendar') {
      return MyRoutePath.calendar();
    } else if (uri.pathSegments.length == 1 &&
        uri.pathSegments[0] == 'groups') {
      return MyRoutePath.groups();
    } else if (uri.pathSegments.length == 1 && uri.pathSegments[0] == 'help') {
      return MyRoutePath.help();
    } else {
      return MyRoutePath.unknown();
    }
  }

  @override
  RouteInformation? restoreRouteInformation(MyRoutePath path) {
    if (path.isUnknown) {
      return const RouteInformation(location: '/404');
    }

    if (path.isLoginPage) {
      return const RouteInformation(location: '/');
    }

    if (path.isHomePage) {
      return const RouteInformation(location: '/home');
    }

    if (path.isCalendarPage) {
      return const RouteInformation(location: '/calendar');
    }

    if (path.isGroupsPage) {
      return const RouteInformation(location: '/groups');
    }

    if (path.isHelpPage) {
      return const RouteInformation(location: '/help');
    }

    return null;
  }
}

class MyRoutePath {
  final bool isLoginPage;
  final bool isHomePage;
  final bool isCalendarPage;
  final bool isGroupsPage;
  final bool isHelpPage;
  final bool isUnknown;

  MyRoutePath.login()
      : isLoginPage = true,
        isHomePage = false,
        isCalendarPage = false,
        isGroupsPage = false,
        isHelpPage = false,
        isUnknown = false;

  MyRoutePath.home()
      : isLoginPage = false,
        isHomePage = true,
        isCalendarPage = false,
        isGroupsPage = false,
        isHelpPage = false,
        isUnknown = false;

  MyRoutePath.calendar()
      : isLoginPage = false,
        isHomePage = false,
        isCalendarPage = true,
        isGroupsPage = false,
        isHelpPage = false,
        isUnknown = false;

  MyRoutePath.groups()
      : isLoginPage = false,
        isHomePage = false,
        isCalendarPage = false,
        isGroupsPage = true,
        isHelpPage = false,
        isUnknown = false;

  MyRoutePath.help()
      : isLoginPage = false,
        isHomePage = false,
        isCalendarPage = false,
        isGroupsPage = false,
        isHelpPage = true,
        isUnknown = false;

  MyRoutePath.unknown()
      : isLoginPage = false,
        isHomePage = false,
        isCalendarPage = false,
        isGroupsPage = false,
        isHelpPage = false,
        isUnknown = true;
}
