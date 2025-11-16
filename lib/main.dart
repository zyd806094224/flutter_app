import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'routes/app_router.dart';

/// 应用程序入口
/// 使用MVVM架构和go_router路由框架
void main() {
  // 确保Flutter绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置系统UI样式（可选）
  // 设置状态栏为透明
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  // 运行应用
  runApp(const MyApp());
}

/// 应用根Widget
/// 配置主题、路由等全局设置
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 创建路由配置
    final router = AppRouter.createRouter();
    
    return MaterialApp.router(
      // 应用标题
      title: 'Flutter App',
      // 调试模式标志
      debugShowCheckedModeBanner: false,
      // 主题配置
      theme: ThemeData(
        // 主色调
        primarySwatch: Colors.blue,
        // 使用Material 3设计
        useMaterial3: true,
        // 颜色方案
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667EEA),
          brightness: Brightness.light,
        ),
        // AppBar主题
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      // 路由配置
      routerConfig: router,
    );
  }
}
