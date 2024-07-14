part of 'hs_connectivity_bloc.dart';

abstract class HSConnectivityLocationEvent {}

class HSConnectivityCheckConnectivityEvent
    extends HSConnectivityLocationEvent {}

class HSConnectivityRequestLocationEvent extends HSConnectivityLocationEvent {}

class HSConnectivityCheckLocationServiceEvent
    extends HSConnectivityLocationEvent {}

class HSConnectivityStartLocationSubscriptionEvent
    extends HSConnectivityLocationEvent {}

class HSConnectivityStopLocationSubscriptionEvent
    extends HSConnectivityLocationEvent {}
