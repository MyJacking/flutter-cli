import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/navigator/bottom_navigator.dart';
import 'package:flutter_demo/page/login_page.dart';
import 'package:flutter_demo/page/register_page.dart';
import 'package:flutter_demo/util/toast.dart';

import 'navigator/hi_navigator.dart';

class FlutterAppRouteDelegate extends RouterDelegate<FlutterRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<FlutterRoutePath> {
  final GlobalKey<NavigatorState> navigatorKey;

  /// 为 Navigator 设置一个key，必要的时候可以通过navigatorKey.currentState来获取NavigatorState对象
  FlutterAppRouteDelegate() : navigatorKey = GlobalKey<NavigatorState>() {
    /// 实现调换逻辑
    HiNavigator.getInstance().registerRouteJump(
        RouteJumpListener(onJumpTo: (RouteStatus routeStatus, {Map args}) {
      _routeStatus = routeStatus;
      if (_routeStatus == RouteStatus.register) {
        id = args["id"];
      }
      notifyListeners();
    }));
  }

  /// 当前路由状态
  RouteStatus _routeStatus = RouteStatus.home;

  /// 存放所有的页面
  List<MaterialPage> pages = [];

  String id;

  @override
  Widget build(BuildContext context) {
    var index = getPageIndex(pages, routeStatus);

    List<MaterialPage> tempPages = pages;

    /// 当前页面是否存在堆栈中 如果存在直接出栈 无需重新创建页面 避免性能消耗
    if (index != -1) {
      /// 要打开的页面在栈中已存在，则将该页面和它上面的所有页面进行出栈
      /// tips 具体规则可以根据需要进行调整，这里要求栈中只允许有一个同样的页面的示例
      tempPages = tempPages.sublist(0, index);
    }

    var page;
    if (routeStatus == RouteStatus.home) {
      /// 跳转到首页时将栈中其它的页面出栈，因为首先不可回退
      pages.clear();
      page = pageWrap(BottomNavigator());
    }
    else if (routeStatus == RouteStatus.register) {
      page = pageWrap(RegisterPage(id: id,));
    }
    else if (routeStatus == RouteStatus.login) {
      page = pageWrap(LoginPage());
    }

    /// 重新创建一个数组，否则pages因引用没有改变路由不会生效
    tempPages = [...tempPages, page];

    // 通知路由发生变化
    HiNavigator.getInstance().notify(tempPages, pages);

    pages = tempPages;

    return WillPopScope(
      /// 修复安卓物理返回键无法返回上一页的问题
      child: Navigator(
        key: navigatorKey,
        pages: pages,
        onPopPage: (route, result) {
          if (route.settings is MaterialPage) {
            // 登录页未登录返回拦截
            if ((route.settings as MaterialPage).child is LoginPage) {
              if (!hasLogin) {
                showWarnToast("请先登录");
                return false;
              }
            }
          }
          // 执行返回操作
          if (!route.didPop(result)) {
            return false;
          }
          var tempPages = [...pages];
          pages.removeLast();

          /// 通知路由发生变化
          HiNavigator.getInstance().notify(pages, tempPages);
          return true;
        },
      ),
      onWillPop: () async => !await navigatorKey.currentState.maybePop(),
    );
  }

  RouteStatus get routeStatus {
    if (_routeStatus != RouteStatus.register && !hasLogin) {
      return _routeStatus = RouteStatus.login;
    } else {
      return _routeStatus;
    }
  }

  /// 用户是否登录
  bool get hasLogin => true;

  @override
  Future<void> setNewRoutePath(FlutterRoutePath path) async {}
}

/// 定义路由数据, path
class FlutterRoutePath {
  final String location;

  FlutterRoutePath.home() : location = "/";
  //
  // FlutterRoutePath.detail() : location = "/detail";
}
