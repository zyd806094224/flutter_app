import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/home/home_viewmodel.dart';
import '../module1/module1_view.dart';
import '../module2/module2_view.dart';
import '../module3/module3_view.dart';
import '../module4/module4_view.dart';

/// 主页面View
/// MVVM架构中的View层，负责主页面的UI展示
/// 包含底部导航栏和4个模块的切换
class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late HomeViewModel _viewModel;
  
  // 各个模块的页面列表
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // 创建ViewModel实例
    _viewModel = HomeViewModel();
    // 初始化各个模块页面
    _pages = [
      const Module1View(),
      const Module2View(),
      const Module3View(),
      const Module4View(),
    ];
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
        // 根据当前选中的索引显示对应的页面
        body: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            return IndexedStack(
              index: viewModel.currentIndex,
              children: _pages,
            );
          },
        ),
        // 底部导航栏
        bottomNavigationBar: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            return BottomNavigationBar(
              // 当前选中的索引
              currentIndex: viewModel.currentIndex,
              // 选中类型：固定类型，所有标签都会显示
              type: BottomNavigationBarType.fixed,
              // 标签选中时的颜色
              selectedItemColor: Theme.of(context).primaryColor,
              // 标签未选中时的颜色
              unselectedItemColor: Colors.grey,
              // 标签图标和文字的大小
              iconSize: 24,
              // 字体大小
              selectedFontSize: 14,
              unselectedFontSize: 12,
              // 导航栏标签列表
              items: viewModel.getBottomNavItems(),
              // 点击导航栏标签时的回调
              onTap: (index) {
                // 更新ViewModel中的当前索引
                viewModel.setCurrentIndex(index);
              },
            );
          },
        ),
      ),
    );
  }
}

