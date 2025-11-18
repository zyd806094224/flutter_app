import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/splash/splash_view.dart';
import '../views/home/home_view.dart';
import '../views/module1/module1_view.dart';
import '../views/module2/module2_view.dart';
import '../views/module3/module3_view.dart';
import '../views/module4/module4_view.dart';
import '../views/webview/webview_view.dart';

/// 应用路由配置类
/// 使用go_router进行路由管理
class AppRouter {
  /// 创建路由配置
  static GoRouter createRouter() {
    return GoRouter(
      // 初始路由路径
      initialLocation: '/splash',
      // 路由配置列表
      routes: [
        // 启动页路由
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashView(),
        ),
        // 主页面路由 - 包含底部导航栏的子路由
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeView(),
          routes: [
            // 模块1路由
            GoRoute(
              path: 'module1',
              name: 'module1',
              builder: (context, state) => const Module1View(),
            ),
            // 模块2路由
            GoRoute(
              path: 'module2',
              name: 'module2',
              builder: (context, state) => const Module2View(),
            ),
            // 模块3路由
            GoRoute(
              path: 'module3',
              name: 'module3',
              builder: (context, state) => const Module3View(),
            ),
            // 模块4路由
            GoRoute(
              path: 'module4',
              name: 'module4',
              builder: (context, state) => const Module4View(),
            ),
          ],
        ),
        // 公共WebView页面路由 - 支持通过URL参数传递要加载的网页地址
        GoRoute(
          path: '/webview',
          name: 'webview',
          builder: (context, state) {
            // 从路由参数中获取URL
            final url = state.uri.queryParameters['url'] ?? '';
            // 从路由参数中获取标题（可选）
            final title = state.uri.queryParameters['title'];
            
            // 如果URL为空，返回错误页面
            if (url.isEmpty) {
              return Scaffold(
                appBar: AppBar(title: const Text('错误')),
                body: const Center(
                  child: Text('URL参数不能为空'),
                ),
              );
            }
            
            return WebViewPage(
              url: url,
              title: title,
            );
          },
        ),
      ],
    );
  }

  /// 便捷方法：跳转到启动页
  static void goToSplash(BuildContext context) {
    context.go('/splash');
  }

  /// 便捷方法：跳转到主页
  static void goToHome(BuildContext context) {
    context.go('/home');
  }

  /// 便捷方法：跳转到模块1
  static void goToModule1(BuildContext context) {
    context.go('/home/module1');
  }

  /// 便捷方法：跳转到模块2
  static void goToModule2(BuildContext context) {
    context.go('/home/module2');
  }

  /// 便捷方法：跳转到模块3
  static void goToModule3(BuildContext context) {
    context.go('/home/module3');
  }

  /// 便捷方法：跳转到模块4
  static void goToModule4(BuildContext context) {
    context.go('/home/module4');
  }

  /// 便捷方法：跳转到公共WebView页面
  /// [url] 要加载的网页URL地址（必填）
  /// [title] 页面标题（可选，如果不提供则自动从网页获取）
  static void goToWebView(
    BuildContext context, {
    required String url,
    String? title,
  }) {
    // 构建带参数的URL
    final uri = Uri(
      path: '/webview',
      queryParameters: {
        'url': url,
        if (title != null) 'title': title,
      },
    );
    context.go(uri.toString());
  }

  /// 便捷方法：使用push方式跳转到公共WebView页面（保留返回栈）
  /// [url] 要加载的网页URL地址（必填）
  /// [title] 页面标题（可选，如果不提供则自动从网页获取）
  static void pushWebView(
    BuildContext context, {
    required String url,
    String? title,
  }) {
    // 构建带参数的URL
    final uri = Uri(
      path: '/webview',
      queryParameters: {
        'url': url,
        if (title != null) 'title': title,
      },
    );
    context.push(uri.toString());
  }
}

