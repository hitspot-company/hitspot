import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hs_search_repository/hs_search.dart';

part 'hs_choose_users_state.dart';

class HSChooseUsersCubit extends Cubit<HSChooseUsersState> {
  HSChooseUsersCubit({
    required this.title,
    required this.description,
  }) : super(const HSChooseUsersState()) {
    // usersSearcher.setHitsPerPage(3);
  }

  final String title;
  final String description;

  final UsersSearcher usersSearcher = HSSearchRepository.instance.usersSearcher;
  HitsSearcher get searcher => usersSearcher.searcher;

  void updateQuery(String query) {
    emit(state.copyWith(query: query));
    searcher.query(query);
  }
}
