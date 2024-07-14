part of 'hs_connectivity_bloc.dart';

abstract class HSConnectivityLocationEvent {}

class HSConnectivityLocationCheckConnectivityEvent
    extends HSConnectivityLocationEvent {}

class HSConnectivityRequestLocationEvent extends HSConnectivityLocationEvent {}
