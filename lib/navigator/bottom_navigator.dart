import 'package:flutter/material.dart';
import 'package:flutter_demo/page/home_page.dart';
import 'package:flutter_demo/page/profile_page.dart';
import 'package:flutter_demo/page/rank_page.dart';
import 'package:flutter_demo/util/color.dart';

import 'hi_navigator.dart';

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({Key key}) : super(key: key);

  @override
  _BottomNavigatorState createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  final _defaultColor = Colors.grey;
  final _activeColor = primary;
  int _currentIndex = 0;
  static int initialPage = 0;
  final PageController _controller = PageController(initialPage: 0);

  List<Widget> _pages;

  bool _hasBuild = false;

  @override
  Widget build(BuildContext context) {
    _pages = [
      HomePage(),
      RankPage(),
      ProfilePage()
    ];

    if (!_hasBuild) {
      /// 页面第一次打开时通知打开的是哪个tab
      HiNavigator.getInstance()
          .onBottomTabChange(initialPage, _pages[initialPage]);
      _hasBuild = true;
    }

    return Scaffold(
      body: PageView(
        controller: _controller,
        children: _pages,
        onPageChanged: (index) => _onJumpTo(index, pageChanged: true),
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => _onJumpTo(index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _activeColor,
        items: [
          _bottomItem('首页', Icons.home, 0),
          _bottomItem('排行', Icons.local_fire_department, 1),
          _bottomItem('我的', Icons.live_tv, 3),
        ],
      ),
    );
  }

  _bottomItem(String title, IconData icon, int index) {
    return BottomNavigationBarItem(
      icon: Icon(icon, color: _defaultColor),
      activeIcon: Icon(icon, color: _activeColor),
      label: title,
    );
  }

  void _onJumpTo(int index, {pageChanged = false}) {
    if (!pageChanged) {
      // 让PageView展示对应的tab
      _controller.jumpToPage(index);
    } else {
      HiNavigator.getInstance().onBottomTabChange(index, _pages[index]);
    }
    setState(() {
      // 控制选中第几个tab
      _currentIndex = index;
    });
  }
}

