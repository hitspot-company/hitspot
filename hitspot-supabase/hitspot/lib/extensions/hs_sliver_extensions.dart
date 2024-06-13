import 'package:flutter/material.dart';

extension HSToSliverExtension on Widget {
  SliverToBoxAdapter get toSliver {
    return SliverToBoxAdapter(child: this);
  }
}
