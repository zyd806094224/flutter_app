import 'package:dio/dio.dart';

/// Header拦截器
/// 统一为所有请求添加必要的公共请求头（如语言、平台、App版本等）
class HeaderInterceptor extends Interceptor {
  HeaderInterceptor({
    required this.languageProvider,
    required this.appVersionProvider,
  });

  /// 当前语言（如 zh-CN/en-US）
  final String Function() languageProvider;

  /// App版本号
  final String Function() appVersionProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll({
      'Accept-Language': languageProvider(),
      'App-Version': appVersionProvider(),
      'Platform': 'flutter',
    });
    super.onRequest(options, handler);
  }
}

