import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(
          context, HSPrediction(description: "", placeID: "", reference: "")),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    mapSearchCubit.updateQuery(query);
    return FutureBuilder<List<HSPrediction>>(
      future: mapSearchCubit.fetchPredictions(),
      builder:
          (BuildContext context, AsyncSnapshot<List<HSPrediction>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const HSLoadingIndicator();
        }
        final List<HSPrediction> predictions = snapshot.data ?? [];
        if (predictions.isEmpty) {
          return Text("No locations found for $query",
              textAlign: TextAlign.center);
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

  @override
  Widget buildSuggestions(BuildContext context) {
    mapSearchCubit.updateQuery(query);
    return FutureBuilder<List<HSPrediction>>(
      future: mapSearchCubit.fetchPredictions(),
      builder:
          (BuildContext context, AsyncSnapshot<List<HSPrediction>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const HSLoadingIndicator();
        }
        final List<HSPrediction> predictions = snapshot.data ?? [];
        if (predictions.isEmpty) {
          return Text("No locations found for $query",
              textAlign: TextAlign.center);
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
