import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/module4/module4_viewmodel.dart';

/// 模块4 View
/// MVVM架构中的View层，负责模块4的UI展示
class Module4View extends StatefulWidget {
  const Module4View({Key? key}) : super(key: key);

  @override
  State<Module4View> createState() => _Module4ViewState();
}

class _Module4ViewState extends State<Module4View> {
  late Module4ViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // 创建ViewModel实例
    _viewModel = Module4ViewModel();
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
          title: const Text('我的'),
          centerTitle: true,
        ),
        body: Consumer<Module4ViewModel>(
          builder: (context, viewModel, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.purple,
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
                    '这是我的模块，您可以在这里开发个人中心相关功能',
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

