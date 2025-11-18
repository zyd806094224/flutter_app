import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../viewmodels/webview/webview_viewmodel.dart';

/// 公共WebView页面
/// MVVM架构中的View层，负责公共WebView的UI展示
/// 可以通过路由传递URL参数来加载不同的网页
class WebViewPage extends StatefulWidget {
  /// 要加载的URL地址（必填）
  final String url;

  /// 页面标题（可选，如果不提供则自动从网页获取）
  final String? title;

  const WebViewPage({
    Key? key,
    required this.url,
    this.title,
  }) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewViewModel _viewModel;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    // 创建ViewModel实例，传入URL和标题
    _viewModel = WebViewViewModel(
      webUrl: widget.url,
      initialTitle: widget.title,
    );
    // 创建WebViewController
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          // 页面开始加载
          onPageStarted: (String url) {
            _viewModel.setLoading(true);
            _viewModel.setLoadingProgress(0.0);
          },
          // 加载进度更新
          onProgress: (int progress) {
            final progressValue = progress / 100.0;
            _viewModel.setLoadingProgress(progressValue);
            // 加载完成时设置加载状态为false
            if (progress == 100) {
              _viewModel.setLoading(false);
            }
          },
          // 页面加载完成
          onPageFinished: (String url) {
            _viewModel.setLoading(false);
            _viewModel.setLoadingProgress(1.0);
            // 获取页面标题
            _webViewController.getTitle().then((title) {
              if (title != null && title.isNotEmpty) {
                _viewModel.setPageTitle(title);
              }
            });
            // 更新导航状态
            _updateNavigationState();
          },
          // 导航状态变化（是否可以返回/前进）
          onNavigationRequest: (NavigationRequest request) {
            // 允许所有导航请求
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    // 监听WebView的导航状态变化
    _updateNavigationState();
  }

  /// 更新导航状态（是否可以返回/前进）
  Future<void> _updateNavigationState() async {
    final canGoBack = await _webViewController.canGoBack();
    final canGoForward = await _webViewController.canGoForward();
    _viewModel.setNavigationState(
      canGoBack: canGoBack,
      canGoForward: canGoForward,
    );
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
        appBar: AppBar(
          title: Consumer<WebViewViewModel>(
            builder: (context, viewModel, child) {
              return Text(viewModel.pageTitle);
            },
          ),
          centerTitle: true,
        ),
        body: Consumer<WebViewViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                // WebView内容
                WebViewWidget(controller: _webViewController),
                // 加载进度条
                if (viewModel.isLoading && viewModel.loadingProgress < 1.0)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: viewModel.loadingProgress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                // 加载中遮罩（可选，如果页面加载较慢时显示）
                if (viewModel.isLoading && viewModel.loadingProgress == 0.0)
                  Container(
                    color: Colors.white.withOpacity(0.8),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

