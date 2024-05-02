import 'package:flutter/material.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Page<void> page() => const MaterialPage<void>(child: HomePage());

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
        body: const CustomScrollView(
      slivers: [
        // _HomeAppBarOne()
      ],
    ));
  }
}

// class _HomeAppBarOne extends StatelessWidget {
//   const _HomeAppBarOne({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SliverAppBar(
//       titleSpacing: 30,
//       title: Row(
//         children: [
//           Expanded(
//             child: Container(
//               height: 200,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage(HSAssets.instance.textLogo),
//                   fit: BoxFit.fitWidth,
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//       actions: [
//         Padding(
//           padding: const EdgeInsets.only(top: 5, bottom: 5, right: 10),
//           child: Row(
//             children: [
//               TextButton(
//                 onPressed: () {},
//                 child: const Text(
//                   "Log in",
//                 ),
//               ),
//               const SizedBox(width: 4),
//               InkWell(
//                 onTap: () {},
//                 child: Container(
//                   height: 70,
//                   width: 100,
//                   decoration: BoxDecoration(
//                     color: HSTheme.instance.mainColor,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Center(
//                     child: Text(
//                       "Sign up",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         )
//       ],
//       elevation: 0.0,
//       pinned: true,
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(-8), // Add this code
//         child: Container(), // Add this code
//       ),
//     );
//   }
// }

// class CustomAppBarTwo extends StatelessWidget {
//   const CustomAppBarTwo({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SliverAppBar(
//       leading: Container(),
//       title: Container(),
//       backgroundColor: Colors.white,
//       expandedHeight: 250,
//       floating: false,
//       elevation: 0,
//       flexibleSpace: LayoutBuilder(
//           builder: (BuildContext context, BoxConstraints constraints) {
//         return FlexibleSpaceBar(
//             collapseMode: CollapseMode.parallax,
//             background: Container(
//                 color: Colors.white,
//                 child: const Column(children: [
//                   Padding(
//                     padding:  EdgeInsets.all(8),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           flex: 1,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Padding(
//                                 padding: EdgeInsets.only(left: 15),
//                                 child: Row(
//                                   children: [
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           "Find Local",
//                                         ),
//                                         Text(
//                                           "Professional For",
//                                         ),
//                                         Text(
//                                           "Pretty Much Anything",
//                                         ),
//                                         SizedBox(
//                                           height: 20,
//                                         ),
//                                       ],
//                                     ),
//                               ],
//                           ),
//                         ),
//                       ],
//                   )
//       }),
//     );
//   }
// }
