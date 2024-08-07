import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/search/cubit/hs_map_search_cubit.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

class MapSearchDelegate extends SearchDelegate<HSPrediction> {
  MapSearchDelegate(this.mapSearchCubit);
  final HSMapSearchCubit mapSearchCubit;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          mapSearchCubit.updateQuery('');
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: backIcon,
      onPressed: () => close(
        context,
        HSPrediction(description: "", placeID: "", reference: ""),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildPredictionsList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    mapSearchCubit.updateQuery(query);
    if (query.isEmpty) {
      return const _SearchPrompt();
    }
    return _buildPredictionsList(context);
  }

  Widget _buildPredictionsList(BuildContext context) {
    return BlocBuilder<HSMapSearchCubit, HSMapSearchState>(
      bloc: mapSearchCubit,
      builder: (context, state) {
        if (state.status == HSMapSearchStatus.loading) {
          return const HSLoadingIndicator();
        }

        if (query.isEmpty) {
          return const _SearchPrompt();
        }
        final List<HSPrediction> predictions = state.predictions;
        if (predictions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  "No results found for '$query'",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: predictions.length,
          separatorBuilder: (BuildContext context, int index) {
            return const Gap(16.0);
          },
          itemBuilder: (BuildContext context, int index) {
            final prediction = predictions[index];
            return GestureDetector(
              onTap: () => close(context, prediction),
              child: ListTile(
                title: Text(prediction.description),
              ),
            );
          },
        );
      },
    );
  }
}

class _SearchPrompt extends StatelessWidget {
  const _SearchPrompt();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            "Enter a location to search",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
