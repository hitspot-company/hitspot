import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

part 'hs_create_trip_state.dart';

class HSCreateTripCubit extends Cubit<HSCreateTripState> {
  HSCreateTripCubit({this.board, this.prototype})
      : super(prototype != null
            ? HSCreateTripState.update(prototype)
            : const HSCreateTripState());

  final HSTrip? prototype;
  final HSBoard? board;
}
