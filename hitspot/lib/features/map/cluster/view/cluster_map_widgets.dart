part of 'cluster_map_page.dart';

class MapBottomSheet extends StatelessWidget {
  const MapBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HsClusterMapCubit>();
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    return DraggableScrollableSheet(
      snap: true,
      snapSizes: const [
        HsClusterMapCubit.SHEET_MIN_SIZE,
        HsClusterMapCubit.SHEET_MAX_SIZE,
      ],
      controller: cubit.scrollController,
      initialChildSize: HsClusterMapCubit.SHEET_MIN_SIZE,
      minChildSize: HsClusterMapCubit.SHEET_MIN_SIZE,
      maxChildSize: HsClusterMapCubit.SHEET_MAX_SIZE,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24.0)),
            boxShadow: [
              if (isLightTheme)
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Handle(),
                  _SearchBar(),
                  _ActionButtons(),
                  Divider(thickness: 0.5, height: 1),
                  _SpotInfo(),
                  Divider(thickness: 0.5, height: 1),
                  SizedBox(height: 16),
                  _SpotList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SpotList extends StatelessWidget {
  const _SpotList();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<HsClusterMapCubit>();
    return BlocSelector<HsClusterMapCubit, HsClusterMapState, List<HSSpot>>(
      selector: (state) => state.visibleSpots,
      builder: (context, spots) {
        if (cubit.state.isSpotSelected) {
          spots.remove(cubit.state.selectedSpot);
        }
        if (spots.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Visible Spots",
                style: Theme.of(context).textTheme.headlineMedium),
            ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 24.0),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: spots.length,
              separatorBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Divider(
                    thickness: .5,
                  )), // SizedBox(height: 16.0),
              itemBuilder: (context, index) {
                final spot = spots[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HSSpotTile(
                      extent: 160.0,
                      spot: spot,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: spot.getTags.map((tag) {
                        return Chip(
                          side: BorderSide.none,
                          label: Text("#$tag"),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(.2),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HsClusterMapCubit>();
    return HSTextField.filled(
      hintText: 'Search for spots...',
      suffixIcon: Icon(Icons.search, color: Theme.of(context).hintColor),
      onTap: () => cubit.fetchSearch(context),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HsClusterMapCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _MapButton(
              icon: FontAwesomeIcons.map,
              backgroundColor: Theme.of(context).primaryColor,
              text: 'Map',
              onPressed: cubit.map,
              foregroundColor: appTheme.mainColor,
            ),
          ),
          Expanded(
            child: _MapButton(
              icon: FontAwesomeIcons.locationCrosshairs,
              text: 'My Location',
              onPressed: cubit.animateToCurrentLocation,
            ),
          ),
          Expanded(
            child: _MapButton(
              icon: FontAwesomeIcons.sliders,
              text: 'Filter',
              onPressed: () => cubit.showFilters(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotInfo extends StatelessWidget {
  const _SpotInfo();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HsClusterMapCubit, HsClusterMapState, bool>(
      selector: (state) => state.isSpotSelected,
      builder: (context, isSpotSelected) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child:
              isSpotSelected ? const _SpotDetails() : const SizedBox.shrink(),
        );
      },
    );
  }
}

class _SpotDetails extends StatelessWidget {
  const _SpotDetails();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HsClusterMapCubit>();
    final spot = cubit.state.selectedSpot;
    return InkWell(
      onTap: () => navi.toSpot(sid: spot.sid!),
      child: Padding(
        key: ValueKey(spot.sid!),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HSImage(
              borderRadius: BorderRadius.circular(8),
              width: screenWidth,
              height: 140,
              imageUrl: spot.getThumbnail,
            ),
            const SizedBox(height: 16),
            Text(
              spot.title!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(spot.getAddress,
                style: Theme.of(context).textTheme.bodySmall!.hintify),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: HSUserTileUp(
                        onTap: () => navi.toUser(userID: spot.createdBy!),
                        user: spot.author!)),
                HSButton.icon(
                  label: const Text("Show on Map"),
                  icon: const Icon(FontAwesomeIcons.mapPin),
                  onPressed: cubit.showSpotOnMap,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(thickness: .5),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _ReactiveSpotButton(
                      reactiveStatus: HSClusterMapStatus.openingDirections,
                      icon: Icons.directions,
                      label: "Directions",
                      onPressed: () => cubit.launchMaps(spot)),
                ),
                Expanded(
                  child: _ReactiveSpotButton(
                      reactiveStatus: HSClusterMapStatus.saving,
                      icon: Icons.bookmark,
                      label: "Save",
                      isActiveCondition: (state) =>
                          state.savedSpots.contains(spot),
                      onPressed: () => cubit.saveSpot(spot)),
                ),
                Expanded(
                  child: _ReactiveSpotButton(
                      reactiveStatus: HSClusterMapStatus.sharing,
                      icon: Icons.share,
                      label: "Share",
                      onPressed: () => cubit.shareSpot(spot)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactiveSpotButton extends StatelessWidget {
  const _ReactiveSpotButton({
    required this.reactiveStatus,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isActiveCondition,
  });

  final HSClusterMapStatus reactiveStatus;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool Function(HsClusterMapState)? isActiveCondition;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HsClusterMapCubit, HsClusterMapState>(
      buildWhen: (previous, current) =>
          (previous.status == HSClusterMapStatus.loaded &&
              current.status == reactiveStatus) ||
          (previous.status == reactiveStatus &&
              current.status == HSClusterMapStatus.loaded),
      builder: (context, state) {
        final bool inProgress = state.status == reactiveStatus;

        if (inProgress) {
          return const HSLoadingIndicator(size: 24.0);
        }

        late final Color? color;
        if (isActiveCondition != null) {
          final isActive = isActiveCondition!(state);
          color = isActive ? appTheme.mainColor : null;
        } else {
          color = null;
        }

        return InkWell(
          onTap: onPressed,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor, foregroundColor;

  const _MapButton({
    required this.icon,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
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
                color: foregroundColor,
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
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
