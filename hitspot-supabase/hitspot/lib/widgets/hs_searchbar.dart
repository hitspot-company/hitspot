// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:hitspot/widgets/hs_textfield.dart';

// class HSSearchBar extends StatelessWidget {
//   const HSSearchBar({super.key, required this.height});

//   final double height;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: height,
//       child: HSTextField(
//         readOnly: true,
//         suffixIcon: const Icon(
//           FontAwesomeIcons.magnifyingGlass,
//           color: Colors.grey,
//         ),
//         fillColor: HSApp.instance.textFieldFillColor,
//         hintText: "Search...",
//         onTap: () async {
//           await showSearch(context: context, delegate: HSHomeSearchDelegate());
//         },
//       ),
//     );
//   }
// }
