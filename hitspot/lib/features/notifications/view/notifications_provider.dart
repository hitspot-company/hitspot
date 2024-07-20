import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/notifications/bloc/hs_notifications_bloc.dart';
import 'package:hitspot/features/notifications/view/notifications_page.dart';

class NotificationsProvider extends StatelessWidget {
  const NotificationsProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HsNotificationsBloc(),
      child: const NotificationsPage(),
    );
  }
}
