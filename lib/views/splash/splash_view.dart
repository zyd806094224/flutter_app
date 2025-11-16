import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/splash/splash_viewmodel.dart';
import '../../routes/app_router.dart';

/// 启动页View
/// MVVM架构中的View层，负责启动页的UI展示
class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  late SplashViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // 创建ViewModel实例
    _viewModel = SplashViewModel();
    // 设置倒计时完成后的回调，跳转到主页面
    _viewModel.setOnCountdownFinished(() {
      if (mounted) {
        AppRouter.goToHome(context);
      }
    });
  }

  @override
  void dispose() {
    // 释放ViewModel资源
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        // 设置背景渐变色
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // 主要内容区域 - 居中显示应用Logo和名称
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 应用Logo（使用图标代替）
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.flutter_dash,
                          size: 80,
                          color: Color(0xFF667EEA),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // 应用名称
                      const Text(
                        'Flutter App',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // 副标题
                      const Text(
                        '欢迎使用',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                // 右上角跳过按钮
                Positioned(
                  top: 20,
                  right: 20,
                  child: Consumer<SplashViewModel>(
                    builder: (context, viewModel, child) {
                      return InkWell(
                        onTap: () {
                          // 手动跳过，跳转到主页面
                          viewModel.skipCountdown();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 显示倒计时
                              Text(
                                '${viewModel.countdown}s',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '跳过',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

