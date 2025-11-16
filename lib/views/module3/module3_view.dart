import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/module3/module3_viewmodel.dart';

/// 模块3 View
/// MVVM架构中的View层，负责模块3的UI展示
class Module3View extends StatefulWidget {
  const Module3View({Key? key}) : super(key: key);

  @override
  State<Module3View> createState() => _Module3ViewState();
}

class _Module3ViewState extends State<Module3View> {
  late Module3ViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // 创建ViewModel实例
    _viewModel = Module3ViewModel();
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
          title: const Text('购物车'),
          centerTitle: true,
        ),
        body: Consumer<Module3ViewModel>(
          builder: (context, viewModel, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart,
                    size: 80,
                    color: Colors.orange,
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
                    '这是购物车模块，您可以在这里开发购物车相关功能',
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

