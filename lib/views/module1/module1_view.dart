import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../models/news_article.dart';
import '../../viewmodels/module1/module1_viewmodel.dart';

/// 模块1 View
/// MVVM架构中的View层，负责模块1的UI展示
class Module1View extends StatefulWidget {
  const Module1View({Key? key}) : super(key: key);

  @override
  State<Module1View> createState() => _Module1ViewState();
}

class _Module1ViewState extends State<Module1View> {
  late final Module1ViewModel _viewModel;
  late final ScrollController _scrollController;
  late final RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    // 创建ViewModel实例
    _viewModel = Module1ViewModel();
    // 创建滚动控制器，用于监听滚动位置和触发吸顶逻辑
    _scrollController = ScrollController()..addListener(_handleScroll);
    // 下拉刷新 / 上拉加载 控制器
    _refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    // 移除监听并释放资源
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _refreshController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  /// 监听滚动事件：1）更新吸顶条目 2）触发加载更多
  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    _viewModel.handleScrollOffset(offset);

    // 距离底部200像素时自动加载更多
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _viewModel.loadMoreNews();
    }
  }

  /// 跳转到指定索引的新闻条目
  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients || index < 0) return;
    if (index >= _viewModel.articles.length) return;

    final targetOffset = index * Module1ViewModel.itemExtent;
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('首页资讯'),
          centerTitle: true,
        ),
        body: Consumer<Module1ViewModel>(
          builder: (context, viewModel, child) {
            return SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: true,
              header: const WaterDropHeader(),
              footer: CustomFooter(
                builder: (context, mode) {
                  if (mode == LoadStatus.loading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  if (mode == LoadStatus.failed) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: Text('加载失败，点击重试')),
                    );
                  }
                  if (mode == LoadStatus.noMore) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          '已经到底啦',
                          style: TextStyle(color: Colors.black45),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              onRefresh: () async {
                await viewModel.refreshNews();
                _refreshController.refreshCompleted();
              },
              onLoading: () async {
                await viewModel.loadMoreNews();
                if (viewModel.hasMore) {
                  _refreshController.loadComplete();
                } else {
                  _refreshController.loadNoData();
                }
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 顶部“正在关注”吸顶卡片上方可以放轮播、Banner等，这里简单空白
                  SliverToBoxAdapter(
                    child: _PinnedArticleHeader(article: viewModel.pinnedArticle),
                  ),
                  // 分区Tab，吸顶
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _CategoryTabHeaderDelegate(
                      minHeight: 48,
                      maxHeight: 52,
                      sections: viewModel.sections,
                      currentIndex: viewModel.currentSectionIndex,
                      onTap: (index) {
                        final startIndex =
                            viewModel.getStartIndexForSection(index);
                        if (startIndex != null) {
                          _scrollToIndex(startIndex);
                        }
                      },
                    ),
                  ),
                  // 列表内容
                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= viewModel.articles.length) {
                            return const SizedBox.shrink();
                          }
                          final article = viewModel.articles[index];
                          return _NewsCard(
                            article: article,
                            index: index,
                          );
                        },
                        childCount: viewModel.articles.length,
                      ),
                    ),
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

/// 吸顶的分区Tab Header委托
class _CategoryTabHeaderDelegate extends SliverPersistentHeaderDelegate {
  /// 最小高度（收起时高度）
  final double minHeight;

  /// 最大高度（展开时高度）
  final double maxHeight;
  final List<String> sections;
  final int currentIndex;
  final ValueChanged<int> onTap;

  _CategoryTabHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.sections,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(sections.length, (index) {
            final bool selected = index == currentIndex;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(sections[index]),
                selected: selected,
                onSelected: (_) => onTap(index),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CategoryTabHeaderDelegate oldDelegate) {
    return oldDelegate.sections != sections ||
        oldDelegate.currentIndex != currentIndex ||
        oldDelegate.minHeight != minHeight ||
        oldDelegate.maxHeight != maxHeight;
  }

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;
}

/// 吸顶头条展示模块
class _PinnedArticleHeader extends StatelessWidget {
  final NewsArticle? article;

  const _PinnedArticleHeader({required this.article});

  @override
  Widget build(BuildContext context) {
    if (article == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      '正在关注',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    article!.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              Text(
                _timeLabel(article!.publishTime),
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            article!.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            article!.summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  /// 将时间转换成易读文案
  static String _timeLabel(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
    }
}

/// 快速定位到指定条目的Chip
class _QuickJumpChips extends StatelessWidget {
  final void Function(int index) onJump;
  final int total;

  const _QuickJumpChips({
    required this.onJump,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) {
      return const SizedBox.shrink();
    }

    final displayCount = total >= 5 ? 5 : total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: List.generate(displayCount, (index) {
          final label = '跳到第${index + 1}条';
          return ActionChip(
            label: Text(label),
            onPressed: () => onJump(index),
          );
        }),
      ),
    );
  }
}

/// 新闻列表卡片
class _NewsCard extends StatelessWidget {
  final NewsArticle article;
  final int index;

  const _NewsCard({
    required this.article,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Module1ViewModel.itemExtent,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 80,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: article.accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '#${index + 1}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      article.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              article.author,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                article.category,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _PinnedArticleHeader._timeLabel(article.publishTime),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 加载更多指示器
class _LoadMoreIndicator extends StatelessWidget {
  final Module1ViewModel viewModel;

  const _LoadMoreIndicator({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (!viewModel.hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            '已经到底啦',
            style: TextStyle(color: Colors.black45),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

