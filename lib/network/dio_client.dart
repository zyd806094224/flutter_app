import 'package:dio/dio.dart';

import 'api_response.dart';
import 'network_exceptions.dart';
import 'request_config.dart';
import 'interceptors/header_interceptor.dart';
import 'interceptors/log_interceptor.dart';
import 'interceptors/token_interceptor.dart';

/// Dio客户端封装
/// - 提供统一的请求方法（GET/POST/PUT/DELETE等）
/// - 内置拦截器管理，方便扩展
/// - 统一处理异常和响应解析
class DioClient {
  DioClient._internal() {
    _dio = Dio(RequestConfig.instance.createBaseOptions())
      ..interceptors.addAll([
        HeaderInterceptor(
          languageProvider: () => 'zh-CN',
          appVersionProvider: () => '1.0.0',
        ),
        TokenInterceptor(
          tokenProvider: () => _token,
          refreshTokenHandler: _refreshToken,
        ),
        AppLogInterceptor(enableLog: true),
      ]);
  }

  static final DioClient _instance = DioClient._internal();

  /// 对外暴露单例
  static DioClient get instance => _instance;

  late final Dio _dio;

  /// 简易 Token 存储，实际可接入本地数据库或安全存储
  String? _token;

  /// 更新 Token
  void updateToken(String? token) => _token = token;

  /// 刷新 Token（示例实现）
  Future<String?> _refreshToken() async {
    // TODO: 调用刷新接口，拿到新 Token 后调用 updateToken
    return _token;
  }

  /// GET 请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? dataParser,
  }) async {
    return _request<T>(
      path,
      method: 'GET',
      queryParameters: queryParameters,
      options: options,
      dataParser: dataParser,
    );
  }

  /// POST 请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    T Function(dynamic data)? dataParser,
  }) async {
    return _request<T>(
      path,
      method: 'POST',
      queryParameters: queryParameters,
      options: options,
      data: data,
      dataParser: dataParser,
    );
  }

  /// 通用请求封装
  Future<ApiResponse<T>> _request<T>(
    String path, {
    required String method,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    T Function(dynamic data)? dataParser,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        options: (options ?? Options()).copyWith(method: method),
        queryParameters: queryParameters,
      );
      if (response.data is Map<String, dynamic>) {
        return ApiResponse<T>.fromJson(
          response.data as Map<String, dynamic>,
          dataParser: dataParser,
        );
      }
      return ApiResponse<T>(
        code: response.statusCode ?? -1,
        message: '响应格式异常',
        data: null,
        raw: response.data,
      );
    } on DioError catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw NetworkException('未知错误：$e');
    }
  }
}

