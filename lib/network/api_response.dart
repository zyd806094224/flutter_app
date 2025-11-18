/// 通用API响应模型
/// 约定后端返回格式为：
/// {
///   "code": 0,
///   "message": "success",
///   "data": { ... }
/// }
class ApiResponse<T> {
  ApiResponse({
    required this.code,
    required this.message,
    this.data,
    this.raw,
  });

  /// 业务状态码
  final int code;

  /// 业务提示信息
  final String message;

  /// 泛型数据
  final T? data;

  /// 原始响应体，方便调试
  final dynamic raw;

  /// 判定是否成功
  bool get isSuccess => (code == 0 || code == 200);

  /// 将 Map 转换为 [ApiResponse]
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic data)? dataParser,
  }) {
    final dynamic rawData = json['data'];
    final parsedData = dataParser != null ? dataParser(rawData) : rawData as T?;
    return ApiResponse<T>(
      code: json['code'] ?? -1,
      message: json['message'] ?? '未知错误',
      data: parsedData,
      raw: json,
    );
  }
}

