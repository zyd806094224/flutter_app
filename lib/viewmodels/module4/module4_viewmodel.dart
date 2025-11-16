import 'package:flutter/material.dart';

/// 模块4 ViewModel
/// MVVM架构中的ViewModel层，负责模块4的业务逻辑
class Module4ViewModel extends ChangeNotifier {
  // 示例数据：模块4的标题
  String _title = '我的模块';

  /// 获取标题
  String get title => _title;

  /// 设置标题（示例方法）
  void setTitle(String title) {
    if (_title != title) {
      _title = title;
      notifyListeners();
    }
  }
}

