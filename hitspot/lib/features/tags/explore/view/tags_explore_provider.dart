import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/tags/explore/cubit/hs_tags_explore_cubit.dart';
import 'package:hitspot/features/tags/explore/view/tags_explore_page.dart';

class TagsExploreProvider extends StatelessWidget {
  const TagsExploreProvider({super.key, required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HsTagsExploreCubit(tag),
      child: const TagsExplorePage(),
    );
  }
}
