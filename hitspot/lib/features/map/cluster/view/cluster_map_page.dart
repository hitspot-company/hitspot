import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/cluster/cubit/hs_cluster_map_cubit.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_spot_tile.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

class ClusterMapPage extends StatelessWidget {
  const ClusterMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HsClusterMapCubit>(context);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        BlocSelector<HsClusterMapCubit, HsClusterMapState, HSClusterMapStatus>(
          selector: (state) => state.status,
          builder: (context, status) {
            if (status == HSClusterMapStatus.loading) {
              return const HSScaffold(body: HSLoadingIndicator());
            }
            return GoogleMap(
              initialCameraPosition: cubit.initialCameraPosition,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              onTap: (argument) => cubit.resetSelectedSpot(),
              onMapCreated: (controller) {
                if (!cubit.mapController.isCompleted) {
                  cubit.mapController.complete(controller);
                }
              },
              markers: cubit.state.markers,
              onCameraIdle: cubit.onCameraIdle,
              onCameraMove: cubit.onCameraMoved,
            );
          },
        ),
        Positioned(
          left: 16.0,
          child: SafeArea(
            child: FloatingActionButton(
              heroTag: 'back',
              onPressed: navi.pop,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: backIcon,
            ),
          ),
        ),
        Positioned(
          right: 16.0,
          child: SafeArea(
            child: FloatingActionButton(
              heroTag: 'myLocation',
              onPressed: cubit.animateToCurrentLocation,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: const Icon(Icons.my_location),
            ),
          ),
        ),
        const AnimatedMapOverlay(),
      ],
    );
  }
}

class AnimatedMapOverlay extends StatelessWidget {
  const AnimatedMapOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HsClusterMapCubit>();
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Material(
          key: ValueKey<bool>(context
              .select((HsClusterMapCubit cubit) => cubit.state.isSpotSelected)),
          elevation: 8,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDragHandle(),
                _buildSelectedSpot(context),
                _buildSearchBar(context, cubit),
                const Divider(thickness: 0.5, height: 1),
                _buildActionButtons(context, cubit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildSelectedSpot(BuildContext context) {
    return BlocSelector<HsClusterMapCubit, HsClusterMapState, bool>(
      selector: (state) => state.isSpotSelected,
      builder: (context, isSpotSelected) {
        if (isSpotSelected) {
          final spot = context.read<HsClusterMapCubit>().state.selectedSpot;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: HSSpotTile(
              index: 0,
              spot: spot,
              extent: 120.0,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, HsClusterMapCubit cubit) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: HSTextField.filled(
        hintText: 'Search for spots...',
        suffixIcon: Icon(Icons.search, color: Theme.of(context).hintColor),
        // suffixIcon: Icon(Icons.mic, color: Theme.of(context).hintColor),
        readOnly: true,
        onTap: () => cubit.fetchSearch(context),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, HsClusterMapCubit cubit) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _MapButton(
            icon: FontAwesomeIcons.map,
            backgroundColor: Theme.of(context).primaryColor,
            text: 'Map',
            onPressed: () {},
          ),
          _MapButton(
            icon: FontAwesomeIcons.locationCrosshairs,
            text: 'Nearby',
            onPressed: cubit.findNearby,
          ),
          _MapButton(
            icon: FontAwesomeIcons.sliders,
            text: 'Filter',
            onPressed: () => cubit.showFilters(context),
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const _MapButton({
    required this.icon,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                icon,
                size: 20,
                color: backgroundColor != null
                    ? Colors.white
                    : Theme.of(context).iconTheme.color,
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: backgroundColor != null
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HSFilterPopup extends StatefulWidget {
  final List<String> filterOptions;
  final List<String> selected;

  const HSFilterPopup(
      {super.key, required this.filterOptions, this.selected = const []});

  @override
  State<HSFilterPopup> createState() => _HSFilterPopupState();
}

class _HSFilterPopupState extends State<HSFilterPopup> {
  late List<String> _selectedFilters;
  late List<String> _allOptions;

  @override
  void initState() {
    super.initState();
    _selectedFilters = List.from(widget.selected);
    _allOptions = {...widget.filterOptions, ..._selectedFilters}.toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Filters'),
      content: SingleChildScrollView(
        child: Wrap(
          spacing: 8.0,
          children: _allOptions.map((option) {
            final isSelected = _selectedFilters.contains(option);
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFilters.add(option);
                  } else {
                    _selectedFilters.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Apply'),
          onPressed: () {
            Navigator.of(context).pop(_selectedFilters);
          },
        ),
      ],
    );
  }
}
