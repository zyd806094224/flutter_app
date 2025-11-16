import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/module1/module1_viewmodel.dart';

/// 模块1 View
/// MVVM架构中的View层，负责模块1的UI展示
class Module1View extends StatefulWidget {
  const Module1View({Key? key}) : super(key: key);

  @override
  State<Module1View> createState() => _Module1ViewState();
}

class _Module1ViewState extends State<Module1View> {
  late Module1ViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // 创建ViewModel实例
    _viewModel = Module1ViewModel();
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
          title: const Text('首页'),
          centerTitle: true,
        ),
        body: Consumer<Module1ViewModel>(
          builder: (context, viewModel, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.home,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    viewModel.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '这是首页模块，您可以在这里开发首页相关功能',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

