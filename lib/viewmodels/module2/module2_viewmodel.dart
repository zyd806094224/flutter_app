import 'package:flutter/material.dart';

/// 模块2 ViewModel
/// MVVM架构中的ViewModel层，负责模块2的业务逻辑
class Module2ViewModel extends ChangeNotifier {
  // WebView 加载的URL地址
  static const String webUrl = 'http://106.15.7.132:3000/';

  // 是否正在加载
  bool _isLoading = true;

  // 加载进度（0.0 - 1.0）
  double _loadingProgress = 0.0;

  // 页面标题
  String _pageTitle = '分类';

  // 是否可以返回上一页
  bool _canGoBack = false;

  // 是否可以前进下一页
  bool _canGoForward = false;

  /// 获取是否正在加载
  bool get isLoading => _isLoading;

  /// 获取加载进度
  double get loadingProgress => _loadingProgress;

  /// 获取页面标题
  String get pageTitle => _pageTitle;

  /// 获取是否可以返回
  bool get canGoBack => _canGoBack;

  /// 获取是否可以前进
  bool get canGoForward => _canGoForward;

  /// 设置加载状态
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// 设置加载进度
  void setLoadingProgress(double progress) {
    if (_loadingProgress != progress) {
      _loadingProgress = progress;
      notifyListeners();
    }
  }

  /// 设置页面标题
  void setPageTitle(String title) {
    if (_pageTitle != title) {
      _pageTitle = title;
      notifyListeners();
    }
  }

  /// 设置导航状态（是否可以返回/前进）
  void setNavigationState({
    bool? canGoBack,
    bool? canGoForward,
  }) {
    bool changed = false;
    if (canGoBack != null && _canGoBack != canGoBack) {
      _canGoBack = canGoBack;
      changed = true;
    }
    if (canGoForward != null && _canGoForward != canGoForward) {
      _canGoForward = canGoForward;
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }
}

