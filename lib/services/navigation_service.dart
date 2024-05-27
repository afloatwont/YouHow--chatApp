import 'package:flutter/material.dart';
import 'package:youhow/pages/homepage.dart';
import 'package:youhow/pages/login_page.dart';
import 'package:youhow/pages/register_page.dart';

class NavigationService {
  late GlobalKey<NavigatorState> _navigatorKey;

  final Map<String, Widget Function(BuildContext)> _routes = {
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterPage(),
    '/home': (context) => const HomePage(),
  };

  NavigationService() {
    _navigatorKey = GlobalKey<NavigatorState>();
  }

  GlobalKey<NavigatorState>? get navigatorKey {
    return _navigatorKey;
  }

  Map<String, Widget Function(BuildContext)> get routes {
    return _routes;
  }

  void push(MaterialPageRoute route) {
    _navigatorKey.currentState?.push(route);
  }

  void pushNamed(String routename) {
    _navigatorKey.currentState?.pushNamed(routename);
  }

  void pop() {
    _navigatorKey.currentState?.pop();
  }

  void pushReplacementNamed(String route) {
    _navigatorKey.currentState?.pushNamed(route);
  }
}
