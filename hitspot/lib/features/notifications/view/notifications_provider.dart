import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/notifications/cubit/hs_notifications_cubit.dart';
import 'package:hitspot/features/notifications/view/notifications_page.dart';

class NotificationsProvider extends StatelessWidget {
  const NotificationsProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HSNotificationsCubit(),
      child: const NotificationsPage(),
    );
  }
}
