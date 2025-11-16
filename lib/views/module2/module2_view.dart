import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/module2/module2_viewmodel.dart';

/// 模块2 View
/// MVVM架构中的View层，负责模块2的UI展示
class Module2View extends StatefulWidget {
  const Module2View({Key? key}) : super(key: key);

  @override
  State<Module2View> createState() => _Module2ViewState();
}

class _Module2ViewState extends State<Module2View> {
  late Module2ViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // 创建ViewModel实例
    _viewModel = Module2ViewModel();
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
          title: const Text('分类'),
          centerTitle: true,
        ),
        body: Consumer<Module2ViewModel>(
          builder: (context, viewModel, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.category,
                    size: 80,
                    color: Colors.green,
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
                    '这是分类模块，您可以在这里开发分类相关功能',
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

