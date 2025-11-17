import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/news_article.dart';

/// 模块1 ViewModel
/// MVVM架构中的ViewModel层，负责模块1的业务逻辑
class Module1ViewModel extends ChangeNotifier {
  /// 列表项固定高度，用于计算吸顶逻辑
  static const double itemExtent = 170;

  /// 每个分区的新闻数量（假数据）
  static const int _sectionSize = 6;

  /// 当前页码
  int _currentPage = 0;

  /// 是否正在刷新
  bool _isRefreshing = false;

  /// 是否正在加载更多
  bool _isLoadingMore = false;

  /// 是否还有更多数据
  bool _hasMore = true;

  /// 当前吸顶新闻索引（用于顶部“正在关注”卡片）
  int _pinnedIndex = 0;

  /// 当前吸顶的分区索引（用于Tab高亮）
  int _currentSectionIndex = 0;

  /// 新闻数据列表
  final List<NewsArticle> _articles = [];

  /// 分区名称列表（类似商城的分类Tab）
  final List<String> _sections = ['热点', '科技', '体育', '财经', '生活'];

  /// 每个分区对应的起始索引（在 _articles 中的下标）
  /// 例如 [0, 6, 12, 18, 24] 表示：
  /// - 热点：0-5
  /// - 科技：6-11
  /// - 体育：12-17
  /// - ...
  final List<int> _sectionStartIndices = [];

  /// 构造函数 - 初始化数据
  Module1ViewModel() {
    _initData();
  }

  /// 初始化时加载一页数据
  Future<void> _initData() async {
    await refreshNews();
  }

  /// 对外暴露只读列表
  List<NewsArticle> get articles => List.unmodifiable(_articles);

  /// 分区Tab列表
  List<String> get sections => List.unmodifiable(_sections);

  /// 当前吸顶分区索引（用于Tab高亮）
  int get currentSectionIndex => _currentSectionIndex;

  bool get isRefreshing => _isRefreshing;

  bool get isLoadingMore => _isLoadingMore;

  bool get hasMore => _hasMore;

  int get pinnedIndex => _pinnedIndex;

  NewsArticle? get pinnedArticle =>
      _articles.isEmpty ? null : _articles[_pinnedIndex];

  /// 根据新闻索引获取它所属的分区索引
  int getSectionIndexForArticle(int articleIndex) {
    if (_sectionStartIndices.isEmpty || articleIndex < 0) return 0;
    for (int i = 0; i < _sectionStartIndices.length; i++) {
      final start = _sectionStartIndices[i];
      final end = (i == _sectionStartIndices.length - 1)
          ? _articles.length
          : _sectionStartIndices[i + 1];
      if (articleIndex >= start && articleIndex < end) {
        return i;
      }
    }
    return 0;
  }

  /// 获取指定分区在列表中的起始索引
  int? getStartIndexForSection(int sectionIndex) {
    if (sectionIndex < 0 ||
        sectionIndex >= _sectionStartIndices.length ||
        _articles.isEmpty) {
      return null;
    }
    return _sectionStartIndices[sectionIndex];
  }

  /// 下拉刷新
  Future<void> refreshNews() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    _hasMore = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 900));

    _articles
      ..clear()
      ..addAll(_generateFakeSectionsData());

    // 计算每个分区的起始索引
    _sectionStartIndices
      ..clear()
      ..addAll(List.generate(_sections.length, (index) {
        return index * _sectionSize;
      }));
    _currentPage = 0;
    _pinnedIndex = 0;
    _currentSectionIndex = 0;
    _isRefreshing = false;
    notifyListeners();
  }

  /// 上拉加载更多
  Future<void> loadMoreNews() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    // 简化处理：将新数据追加到最后一个分区，模拟“更多推荐”
    final newData = _generateFakeSectionData(
      sectionName: '推荐',
      startId: _articles.length + 1,
    );

    if (newData.isEmpty) {
      _hasMore = false;
    } else {
      // 若不存在“推荐”分区，则追加一个
      if (!_sections.contains('推荐')) {
        _sections.add('推荐');
        _sectionStartIndices.add(_articles.length);
      }
      _articles.addAll(newData);
      _currentPage++;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  /// 根据滚动位置更新吸顶索引
  void handleScrollOffset(double offset) {
    if (_articles.isEmpty) return;

    final index = offset ~/ itemExtent;
    final clamped = index.clamp(0, _articles.length - 1);
    if (clamped != _pinnedIndex) {
      _pinnedIndex = clamped;
      // 根据当前条目更新分区索引
      final secIndex = getSectionIndexForArticle(_pinnedIndex);
      if (secIndex != _currentSectionIndex) {
        _currentSectionIndex = secIndex;
      }
      notifyListeners();
    }
  }

  /// 构造初始分区假数据（商城类似分区）
  List<NewsArticle> _generateFakeSectionsData() {
    final List<NewsArticle> list = [];
    int id = 1;
    for (final section in _sections) {
      list.addAll(_generateFakeSectionData(sectionName: section, startId: id));
      id += _sectionSize;
    }
    return list;
  }

  /// 构造单个分区的假数据
  List<NewsArticle> _generateFakeSectionData({
    required String sectionName,
    required int startId,
  }) {
    final random = Random(startId);
    final List<Color> colors = [
      const Color(0xFFE8F3FF),
      const Color(0xFFFFF4E5),
      const Color(0xFFE6F7F0),
      const Color(0xFFFFEEF0),
      const Color(0xFFEDEBFF),
    ];

    return List.generate(_sectionSize, (index) {
      final id = startId + index;
      final color = colors[id % colors.length];
      final author = '记者${String.fromCharCode(65 + id % 26)}';

      return NewsArticle(
        id: 'news_$id',
        title: '[$sectionName] 第$id条资讯标题：Flutter商城列表示例',
        summary:
            '这是一段示例摘要，介绍新闻的主要内容与亮点。该条目展示了Flutter列表、刷新、吸顶等交互效果，帮助初学者快速理解。',
        author: author,
        publishTime: DateTime.now()
            .subtract(Duration(minutes: id * random.nextInt(6) + id)),
        category: sectionName,
        accentColor: color,
      );
    });
  }
}

