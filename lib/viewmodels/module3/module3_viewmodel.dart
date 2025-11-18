import 'package:flutter/material.dart';

import '../../network/dio_client.dart';
import '../../network/network_exceptions.dart';

/// 模块3 ViewModel
/// MVVM架构中的ViewModel层，负责购物车模块的业务逻辑
class Module3ViewModel extends ChangeNotifier {
  // 标题
  String _title = '购物车模块';

  // 请求结果提示
  String _resultMessage = '尚未发起请求';

  // 是否正在加载
  bool _isLoading = false;

  String get title => _title;

  String get resultMessage => _resultMessage;

  bool get isLoading => _isLoading;

  /// 设置标题（示例方法）
  void setTitle(String title) {
    if (_title != title) {
      _title = title;
      notifyListeners();
    }
  }

  /// 调用示例接口：GET /user/test
  /// 用于演示如何通过DioClient发起网络请求
  Future<void> fetchGetTest() async {
    if (_isLoading) return;
    _isLoading = true;
    _resultMessage = '请求中...';
    notifyListeners();

    try {
      final response = await DioClient.instance
          .get<Map<String, dynamic>>('/user/test', dataParser: (data) {
        if (data is Map<String, dynamic>) {
          return data;
        }
        return {'data': data};
      });

      if (response.isSuccess) {
        _resultMessage = '请求成功：${response.data ?? response.raw}';
      } else {
        _resultMessage = '业务失败(${response.code})：${response.message}';
      }
    } on NetworkException catch (e) {
      _resultMessage = '请求失败：${e.message}';
    } catch (e) {
      _resultMessage = '未知错误：$e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
