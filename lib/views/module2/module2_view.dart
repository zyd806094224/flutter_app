import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../viewmodels/module2/module2_viewmodel.dart';

/// 模块2 View
/// MVVM架构中的View层，负责模块2的UI展示
/// 使用WebView加载网页内容
class Module2View extends StatefulWidget {
  const Module2View({Key? key}) : super(key: key);

  @override
  State<Module2View> createState() => _Module2ViewState();
}

class _Module2ViewState extends State<Module2View> {
  late Module2ViewModel _viewModel;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    // 创建ViewModel实例
    _viewModel = Module2ViewModel();
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
      ..loadRequest(Uri.parse(Module2ViewModel.webUrl));

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
          title: Consumer<Module2ViewModel>(
            builder: (context, viewModel, child) {
              return Text(viewModel.pageTitle);
            },
          ),
          centerTitle: true,
          // 底部工具栏：返回、前进、刷新按钮
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Consumer<Module2ViewModel>(
              builder: (context, viewModel, child) {
                return Container(
                  height: 48,
                  color: Theme.of(context).appBarTheme.backgroundColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 返回按钮
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: viewModel.canGoBack
                            ? () async {
                                await _webViewController.goBack();
                                _updateNavigationState();
                              }
                            : null,
                        tooltip: '返回',
                      ),
                      // 前进按钮
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: viewModel.canGoForward
                            ? () async {
                                await _webViewController.goForward();
                                _updateNavigationState();
                              }
                            : null,
                        tooltip: '前进',
                      ),
                      // 刷新按钮
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          _webViewController.reload();
                        },
                        tooltip: '刷新',
                      ),
                      // 主页按钮
                      IconButton(
                        icon: const Icon(Icons.home),
                        onPressed: () {
                          _webViewController.loadRequest(
                            Uri.parse(Module2ViewModel.webUrl),
                          );
                        },
                        tooltip: '主页',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        body: Consumer<Module2ViewModel>(
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

