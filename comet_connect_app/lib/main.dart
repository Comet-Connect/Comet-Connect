// ignore_for_file: library_private_types_in_public_api, avoid_renaming_method_parameters

import 'package:comet_connect_app/pages/help_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_or_signup.dart';
import 'pages/homepage.dart';
import 'pages/groups_page.dart';
import 'pages/selectdate.dart';
import 'pages/group_details_page.dart';

// Main
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? loggedIn = prefs.getBool('loggedin');
  runApp(MyApp(
      initialPage:
          loggedIn == true ? MyRoutePath.home() : MyRoutePath.login()));
}

class MyApp extends StatefulWidget {
  final MyRoutePath initialPage;

  const MyApp({Key? key, required this.initialPage}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final routerDelegate = MyRouterDelegate();
  final routeInformationParser = MyRouteInformationParser();

  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  void autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? loggedIn = prefs.getBool('loggedin');

    if (loggedIn == true) {
      routerDelegate.setNewRoutePath(MyRoutePath.home());
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
      backButtonDispatcher: RootBackButtonDispatcher(),
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
      child: GroupsPage(),
    ),
    MaterialPage(
      key: const ValueKey('help'),
      child: HelpPage(),
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
          key: ValueKey('groups'),
          child: GroupsPage(),
        ),
      );
    } else if (path.isGroupDetailsPage) {
      final groupId = path.groupId!;
      _pages.add(
        MaterialPage(
          key: ValueKey('GroupDetailsPage$groupId'),
          child: GroupDetailsPage(
            groupId: groupId,
            groupName: '',
            session_id: '',
            users: const [],
          ),
        ),
      );
    } else if (path.isHelpPage) {
      _pages.add(
        const MaterialPage(
          key: ValueKey('help'),
          child: GroupsPage(),
        ),
      );
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
    } else if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'group') {
      final groupId = uri.pathSegments[1];
      return MyRoutePath.groupDetails(groupId);
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
  final bool isGroupDetailsPage;
  final bool isHelpPage;
  final bool isUnknown;
  final String? groupId;

  MyRoutePath.login()
      : isLoginPage = true,
        isHomePage = false,
        isCalendarPage = false,
        isGroupsPage = false,
        isGroupDetailsPage = false,
        isHelpPage = false,
        isUnknown = false,
        groupId = null;

  MyRoutePath.home()
      : isLoginPage = false,
        isHomePage = true,
        isCalendarPage = false,
        isGroupsPage = false,
        isGroupDetailsPage = false,
        isHelpPage = false,
        isUnknown = false,
        groupId = null;

  MyRoutePath.calendar()
      : isLoginPage = false,
        isHomePage = false,
        isCalendarPage = true,
        isGroupsPage = false,
        isGroupDetailsPage = false,
        isHelpPage = false,
        isUnknown = false,
        groupId = null;

  MyRoutePath.groups()
      : isLoginPage = false,
        isHomePage = false,
        isCalendarPage = false,
        isGroupsPage = true,
        isGroupDetailsPage = false,
        isHelpPage = false,
        isUnknown = false,
        groupId = null;

  MyRoutePath.groupDetails(String this.groupId)
      : isLoginPage = false,
        isHomePage = false,
        isCalendarPage = false,
        isGroupsPage = false,
        isGroupDetailsPage = true,
        isHelpPage = false,
        isUnknown = false;

  MyRoutePath.help()
      : isLoginPage = false,
        isHomePage = false,
        isCalendarPage = false,
        isGroupsPage = false,
        isGroupDetailsPage = false,
        isHelpPage = true,
        isUnknown = false,
        groupId = null;

  MyRoutePath.unknown()
      : isLoginPage = false,
        isHomePage = false,
        isCalendarPage = false,
        isGroupsPage = false,
        isGroupDetailsPage = false,
        isHelpPage = false,
        isUnknown = true,
        groupId = null;
}
