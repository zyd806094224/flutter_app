import 'package:flutter/material.dart';

/// 主页面ViewModel
/// MVVM架构中的ViewModel层，负责主页面的业务逻辑
class HomeViewModel extends ChangeNotifier {
  // 当前选中的底部导航栏索引
  int _currentIndex = 0;

  /// 获取当前选中的索引
  int get currentIndex => _currentIndex;

  /// 设置当前选中的索引
  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// 底部导航栏标签配置
  /// 返回每个标签的信息：标题和图标
  List<BottomNavigationBarItem> getBottomNavItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: '首页',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.category),
        label: '分类',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart),
        label: '购物车',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: '我的',
      ),
    ];
  }
}

