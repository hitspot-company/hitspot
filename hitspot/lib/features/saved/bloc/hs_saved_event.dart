part of 'hs_saved_bloc.dart';

sealed class HSSavedEvent extends Equatable {
  const HSSavedEvent();

  @override
  List<Object> get props => [];
}

final class HSSavedFetchInitial extends HSSavedEvent {}
