import 'dart:async';
import 'package:flutter/material.dart';

/// 启动页ViewModel
/// MVVM架构中的ViewModel层，负责启动页的业务逻辑
class SplashViewModel extends ChangeNotifier {
  // 倒计时总时长（秒）
  static const int _countdownDuration = 2;
  
  // 当前倒计时数值
  int _countdown = _countdownDuration;
  
  // 是否正在倒计时
  bool _isCounting = false;
  
  // Timer对象，用于倒计时
  Timer? _timer;

  /// 获取当前倒计时数值
  int get countdown => _countdown;

  /// 获取是否正在倒计时
  bool get isCounting => _isCounting;

  /// 构造函数
  SplashViewModel() {
    // 页面创建时自动开始倒计时
    startCountdown();
  }

  /// 开始倒计时
  void startCountdown() {
    if (_isCounting) return;
    
    _isCounting = true;
    _countdown = _countdownDuration;
    notifyListeners();

    // 每秒更新一次倒计时
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        _countdown--;
        notifyListeners();
      } else {
        // 倒计时结束，停止计时器
        stopCountdown();
        // 通知监听者倒计时已完成
        _onCountdownFinished?.call();
      }
    });
  }

  /// 停止倒计时
  void stopCountdown() {
    _timer?.cancel();
    _timer = null;
    _isCounting = false;
    notifyListeners();
  }

  /// 跳过倒计时（手动点击跳过按钮时调用）
  void skipCountdown() {
    stopCountdown();
    // 通知监听者用户手动跳过了
    _onCountdownFinished?.call();
  }

  /// 倒计时完成回调
  /// 当倒计时结束或用户手动跳过时会被调用
  void Function()? _onCountdownFinished;

  /// 设置倒计时完成回调
  void setOnCountdownFinished(void Function() callback) {
    _onCountdownFinished = callback;
  }

  @override
  void dispose() {
    // 释放资源
    _timer?.cancel();
    super.dispose();
  }
}

