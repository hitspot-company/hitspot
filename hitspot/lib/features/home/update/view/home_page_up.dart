import 'package:flutter/material.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

SliverPersistentHeader makeHeader(String headerText) {
  return SliverPersistentHeader(
    pinned: true,
    delegate: _SliverAppBarDelegate(
      minHeight: 60.0,
      maxHeight: 200.0,
      child: Container(
        color: Colors.lightBlue,
        child: Center(
          child: Text(
            headerText,
            style: TextStyle(
              fontSize: 30.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}

class HomePageUp extends StatelessWidget {
  const HomePageUp({super.key});

  @override
  Widget build(BuildContext context) {
    return const HSScaffold(body: Text("To be implemented")
        //     CustomScrollView(
        //   slivers: [
        //     SliverPersistentHeader(
        //         delegate: _SliverAppBarDelegate(
        //             minHeight: 80,
        //             maxHeight: 80,
        //             child: Row(
        //               children: [],
        //             )))
        //   ],
        // )
        );
  }
}
