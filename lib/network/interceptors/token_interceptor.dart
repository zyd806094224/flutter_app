import 'dart:async';

import 'package:dio/dio.dart';

/// Token拦截器
/// 负责在请求前添加鉴权 Token，并在 Token 失效时尝试刷新
class TokenInterceptor extends Interceptor {
  TokenInterceptor({
    required this.tokenProvider,
    required this.refreshTokenHandler,
  });

  /// 同步获取当前可用的 Token
  final String? Function() tokenProvider;

  /// Token 失效时的刷新回调
  /// 返回新的 Token，若刷新失败则返回 null
  final Future<String?> Function() refreshTokenHandler;

  /// 是否正在刷新 Token，避免并发重复刷新
  bool _isRefreshing = false;

  /// 暂存等待刷新结果的请求
  final List<void Function()> _pendingRetryCallbacks = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    if (response?.statusCode == 401) {
      final requestOptions = err.requestOptions;

      // 如果当前已有刷新操作，等待刷新完成
      if (_isRefreshing) {
        final completer = Completer<Response>();
        _pendingRetryCallbacks.add(() async {
          try {
            final clonedResponse = await err.requestOptions
                .retry(requestOptions.cancelToken);
            completer.complete(clonedResponse);
          } catch (e) {
            completer.completeError(e);
          }
        });
        return completer.future.then(handler.resolve).catchError(handler.reject);
      }

      _isRefreshing = true;
      try {
        final newToken = await refreshTokenHandler();
        _isRefreshing = false;

        for (final callback in _pendingRetryCallbacks) {
          callback();
        }
        _pendingRetryCallbacks.clear();

        if (newToken != null && newToken.isNotEmpty) {
          requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse =
              await err.requestOptions.retry(requestOptions.cancelToken);
          return handler.resolve(retryResponse);
        }
      } catch (e) {
        _isRefreshing = false;
      }
    }
    super.onError(err, handler);
  }
}

extension _RequestOptionsRetry on RequestOptions {
  /// 重新发起原始请求
  Future<Response<T>> retry<T>(CancelToken? cancelToken) {
    final dio = Dio()
      ..options = BaseOptions(
        method: method,
        headers: headers,
        responseType: responseType,
      );
    return dio.request<T>(
      path,
      queryParameters: queryParameters,
      data: data,
      cancelToken: cancelToken,
      options: Options(method: method),
    );
  }
}

