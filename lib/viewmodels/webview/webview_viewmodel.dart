import 'package:flutter/material.dart';

/// 公共WebView ViewModel
/// MVVM架构中的ViewModel层，负责公共WebView的业务逻辑
class WebViewViewModel extends ChangeNotifier {
  // WebView 加载的URL地址（通过构造函数传入）
  final String webUrl;

  // 页面标题（可选，如果未提供则使用URL）
  final String? initialTitle;

  // 是否正在加载
  bool _isLoading = true;

  // 加载进度（0.0 - 1.0）
  double _loadingProgress = 0.0;

  // 页面标题
  String _pageTitle = '';

  // 是否可以返回上一页
  bool _canGoBack = false;

  // 是否可以前进下一页
  bool _canGoForward = false;

  /// 构造函数
  WebViewViewModel({
    required this.webUrl,
    this.initialTitle,
  }) {
    // 初始化页面标题
    _pageTitle = initialTitle ?? _extractTitleFromUrl(webUrl);
  }

  /// 从URL中提取标题（简单提取域名部分）
  String _extractTitleFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      if (host.isNotEmpty) {
        return host;
      }
      return '网页';
    } catch (e) {
      return '网页';
    }
  }

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

