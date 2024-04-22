part of 'hs_choose_hashtags_cubit.dart';

sealed class HSChooseHashtagsState extends Equatable {
  const HSChooseHashtagsState({this.chosenHashtags = const []});

  final List<Object?> chosenHashtags;

  HSChooseHashtagsState copyWith({required List<Object?> chosenHashtags});

  @override
  List<Object> get props => [chosenHashtags];
}

final class HSChooseHashtagsUpdate extends HSChooseHashtagsState {
  const HSChooseHashtagsUpdate({super.chosenHashtags});

  @override
  HSChooseHashtagsUpdate copyWith({required List<Object?> chosenHashtags}) {
    return HSChooseHashtagsUpdate(chosenHashtags: chosenHashtags);
  }

  @override
  List<Object> get props => [chosenHashtags];
}
