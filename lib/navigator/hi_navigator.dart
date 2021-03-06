import 'package:flutter/material.dart';
import 'package:flutter_demo/navigator/bottom_navigator.dart';
import 'package:flutter_demo/page/home_page.dart';
import 'package:flutter_demo/page/login_page.dart';
import 'package:flutter_demo/page/profile_page.dart';
import 'package:flutter_demo/page/register_page.dart';
import 'package:url_launcher/url_launcher.dart';

typedef RouteChangeListener = Function(
    RouteStatusInfo current, RouteStatusInfo pre);

/// 创建页面
pageWrap(Widget child) {
  return MaterialPage(key: ValueKey(child.hashCode), child: child);
}

/// 路由信息
class RouteStatusInfo {
  final RouteStatus routeStatus;
  final Widget page;

  RouteStatusInfo(this.routeStatus, this.page);
}


/// 获取routeStatus在页面栈中的位置
int getPageIndex(List<MaterialPage> pages, RouteStatus routeStatus) {
  for (int i = 0; i < pages.length; i++) {
    MaterialPage page = pages[i];
    if (getStatus(page) == routeStatus) {
      return i;
    }
  }
  return -1;
}
enum RouteStatus { home, profile, rank, unknown, register, login }

/// 获取path对应的RouteStatus
RouteStatus getStatus(MaterialPage page) {
  if (page.child is HomePage) {
    return RouteStatus.home;
  } else if (page.child is ProfilePage) {
    return RouteStatus.profile;
  } else if (page.child is BottomNavigator) {
    return RouteStatus.home;
  } else if (page.child is RegisterPage) {
    return RouteStatus.register;
  } else if (page.child is LoginPage) {
    return RouteStatus.login;
  } else {
    return RouteStatus.unknown;
  }
}



/// 监听路由页面跳转
/// 感知当前页面是否压后台

class HiNavigator extends _RouteJumpListener {
  static HiNavigator _instance;

  RouteJumpListener _routeJump;

  List<RouteChangeListener> _listeners = [];

  /// 打开过的页面
  RouteStatusInfo _current;

  /// 首页底部tab
  RouteStatusInfo _bottomTab;

  HiNavigator._();

  static HiNavigator getInstance() {
    if (_instance == null) {
      _instance = HiNavigator._();
    }
    return _instance;
  }

  RouteStatusInfo getCurrent() {
    return _current;
  }

  Future<bool> openH5(String url) async {
    var result = await canLaunch(url);
    if (result) {
      return await launch(url);
    } else {
      return Future.value(false);
    }
  }

  /// 首页底部tab切换监听
  void onBottomTabChange(int index, Widget page) {
    _bottomTab = RouteStatusInfo(RouteStatus.home, page);
    _notify(_bottomTab);
  }

  /// 注册路由跳转逻辑
  void registerRouteJump(RouteJumpListener routeJumpListener) {
    _routeJump = routeJumpListener;
  }

  /// 监听路由页面跳转
  void addListener(RouteChangeListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  /// 移除监听
  void removeListener(RouteChangeListener listener) {
    _listeners.remove(listener);
  }

  /// 路由跳转
  @override
  void onJumpTo(RouteStatus routeStatus, {Map args}) {
    if (args != null) {
      _routeJump.onJumpTo(routeStatus, args: args);
    } else {
      _routeJump.onJumpTo(routeStatus);
    }
  }

  /// 通知路由页面变化
  void notify(List<MaterialPage> currentPages, List<MaterialPage> prePages) {
    if (currentPages == prePages) return;
    var current =
    RouteStatusInfo(getStatus(currentPages.last), currentPages.last.child);

    _notify(current);
  }

  void _notify(RouteStatusInfo current) {
    if (current.page is BottomNavigator && _bottomTab != null) {
      /// 如果打开的是首页，则明确到首页具体的tab
      current = _bottomTab;
    }

    print("hi_navigator:current: ${current.page}");
    print("hi_navigator:pre: ${_current?.page}");
    for (var listener in _listeners) {
      if (_current != null) {
        listener(current, _current);
      } else {
        listener(current, current);
      }
    }
    _current = current;
  }
}


abstract class _RouteJumpListener {
  void onJumpTo(RouteStatus routeStatus, {Map args});
}

typedef OnJumpTo = void Function(RouteStatus routeStatus, {Map args});

/// 定义路由跳转逻辑要实现的功能
class RouteJumpListener {
  final OnJumpTo onJumpTo;

  RouteJumpListener({this.onJumpTo});
}
