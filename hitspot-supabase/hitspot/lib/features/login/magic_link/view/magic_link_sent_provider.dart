import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/login/magic_link/cubit/hs_magic_link_cubit.dart';
import 'package:hitspot/features/login/magic_link/view/magic_link_sent_page.dart';

class MagicLinkSentProvider extends StatelessWidget {
  const MagicLinkSentProvider({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HSMagicLinkCubit(email: email),
      child: const MagicLinkSentPage(),
    );
  }
}
