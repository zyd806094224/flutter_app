import 'package:flutter/material.dart';

/// 新闻数据模型
/// 在真实项目中这里会对应后端返回的数据结构
class NewsArticle {
  /// 新闻唯一ID
  final String id;

  /// 新闻标题
  final String title;

  /// 新闻摘要
  final String summary;

  /// 作者
  final String author;

  /// 发布时间
  final DateTime publishTime;

  /// 分类标签
  final String category;

  /// 封面配色（用于示例卡片背景）
  final Color accentColor;

  NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.author,
    required this.publishTime,
    required this.category,
    required this.accentColor,
  });
}

