import 'package:dio/dio.dart';

/// 网络请求配置
/// 用于集中管理不同环境下的域名、超时时间等全局配置，方便企业级扩展
class RequestConfig {
  /// 构造函数私有化，使用 [RequestConfig.instance] 获取单例
  RequestConfig._internal();

  static final RequestConfig _instance = RequestConfig._internal();

  /// 全局唯一实例
  static RequestConfig get instance => _instance;

  /// 枚举：运行环境
  /// 真实项目中可以通过编译参数 / 环境变量动态设置
  Environment environment = Environment.dev;

  /// 环境对应的域名映射
  /// TODO: 根据实际项目补充 QA、灰度等环境
  final Map<Environment, String> _baseUrls = {
    Environment.dev: 'http://192.168.213.9:8060',
    Environment.qa: 'http://192.168.213.9:8060',
    Environment.prod: 'http://192.168.213.9:8060',
  };

  /// 请求超时时间配置
  /// 根据企业级需求，分别设置连接 / 接收 / 发送超时
  Duration connectTimeout = const Duration(seconds: 10);
  Duration receiveTimeout = const Duration(seconds: 15);
  Duration sendTimeout = const Duration(seconds: 10);

  /// 获取当前环境对应的基础域名
  String get baseUrl => _baseUrls[environment] ?? _baseUrls[Environment.dev]!;

  /// 创建 Dio 默认配置
  BaseOptions createBaseOptions() {
    return BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );
  }
}

/// 网络环境枚举
enum Environment {
  dev,
  qa,
  prod,
}

