import 'package:dio/dio.dart';

/// 网络异常解析器
/// 将 Dio 抛出的错误转换为可读文案，便于 UI 层直接展示
class NetworkException implements Exception {
  NetworkException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => 'NetworkException(code: $code, message: $message)';

  /// 将 DioError 转换为 [NetworkException]
  factory NetworkException.fromDioError(DioError error) {
    switch (error.type) {
      case DioErrorType.connectionTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        return NetworkException('请求超时，请检查网络后重试');
      case DioErrorType.badCertificate:
        return NetworkException('证书校验失败，请联系管理员');
      case DioErrorType.badResponse:
        final status = error.response?.statusCode ?? -1;
        final message = error.response?.data is Map
            ? error.response?.data['message']?.toString()
            : error.message;
        return NetworkException(message ?? '服务器开小差啦', code: status);
      case DioErrorType.cancel:
        return NetworkException('请求已取消');
      case DioErrorType.connectionError:
        return NetworkException('无法连接服务器，请检查网络');
      case DioErrorType.unknown:
      default:
        return NetworkException('未知错误：${error.message}');
    }
  }
}

