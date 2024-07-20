import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'hs_notifications_event.dart';
part 'hs_notifications_state.dart';

class HsNotificationsBloc extends Bloc<HsNotificationsEvent, HsNotificationsState> {
  HsNotificationsBloc() : super(HsNotificationsInitial()) {
    on<HsNotificationsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
