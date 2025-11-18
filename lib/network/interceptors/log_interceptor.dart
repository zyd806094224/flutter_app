import 'dart:developer';

import 'package:dio/dio.dart';

/// 日志拦截器
/// 采用 Dart 自带的 log 打印，方便统一收集与过滤
class AppLogInterceptor extends Interceptor {
  AppLogInterceptor({this.enableLog = true});

  final bool enableLog;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enableLog) {
      log(
        '➡️ [${options.method}] ${options.uri}\n'
        'Headers: ${options.headers}\n'
        'Query: ${options.queryParameters}\n'
        'Body: ${options.data}',
        name: 'Dio-Request',
      );
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (enableLog) {
      log(
        '✅ [${response.statusCode}] ${response.requestOptions.uri}\n'
        'Data: ${response.data}',
        name: 'Dio-Response',
      );
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (enableLog) {
      log(
        '❌ [${err.response?.statusCode}] ${err.requestOptions.uri}\n'
        'Error: ${err.message}\n'
        'Stack: ${err.stackTrace}',
        name: 'Dio-Error',
      );
    }
    super.onError(err, handler);
  }
}

