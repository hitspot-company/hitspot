part of 'cluster_map_page.dart';

class MapBottomSheet extends StatelessWidget {
  const MapBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HsClusterMapCubit>();
    return DraggableScrollableSheet(
      controller: cubit.scrollController,
      initialChildSize: HsClusterMapCubit.SHEET_MIN_SIZE,
      minChildSize: HsClusterMapCubit.SHEET_MIN_SIZE,
      maxChildSize: HsClusterMapCubit.SHEET_MAX_SIZE,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
            boxShadow: [
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHandle(),
                _buildSearchBar(context),
                _buildActionButtons(context),
                const Divider(thickness: 0.5, height: 1),
                _buildSpotInfo(context),
                // _buildHeader(context),
                // const Divider(thickness: 0.5, height: 1),
                // _buildExpandedContent(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpotInfo(BuildContext context) {
    final cubit = context.read<HsClusterMapCubit>();
    return BlocSelector<HsClusterMapCubit, HsClusterMapState, bool>(
      selector: (state) => state.isSpotSelected,
      builder: (context, isSpotSelected) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: isSpotSelected
              ? _buildSpotDetails(context, cubit)
              : const SizedBox(),
        );
      },
    );
  }

  Widget _buildSpotDetails(BuildContext context, HsClusterMapCubit cubit) {
    final spot = cubit.state.selectedSpot;
    return Padding(
      key: ValueKey(spot.sid!),
      padding: const EdgeInsets.all(16.0),
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
          Text(spot.address!,
              style: Theme.of(context).textTheme.bodySmall!.hintify),
          const SizedBox(height: 8),
          HsUserTile(user: spot.author!),
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
    );
  }

  Widget _buildHandle() {
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

  Widget _buildSearchBar(BuildContext context) {
    final cubit = context.read<HsClusterMapCubit>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for spots...',
          suffixIcon: Icon(Icons.search, color: Theme.of(context).hintColor),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        readOnly: true,
        onTap: () => cubit.fetchSearch(context),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final cubit = context.read<HsClusterMapCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _MapButton(
              icon: FontAwesomeIcons.map,
              backgroundColor: Theme.of(context).primaryColor,
              text: 'Map',
              onPressed: cubit.map,
            ),
          ),
          Expanded(
            child: _MapButton(
              icon: FontAwesomeIcons.locationCrosshairs,
              text: 'Nearby',
              onPressed: cubit.findNearby,
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

class _ReactiveSpotButton extends StatelessWidget {
  const _ReactiveSpotButton(
      {required this.reactiveStatus,
      required this.icon,
      required this.label,
      required this.onPressed});

  final HSClusterMapStatus reactiveStatus;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  // final Function(bool) isActive;

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
        return InkWell(
          onTap: onPressed,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: inProgress ? appTheme.mainColor : null),
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

class _CompactOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HsClusterMapCubit>();
    return Container(
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
          _buildSearchBar(context, cubit),
          const Divider(thickness: 0.5, height: 1),
          _buildActionButtons(context, cubit),
        ],
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

  Widget _buildSearchBar(BuildContext context, HsClusterMapCubit cubit) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: HSTextField.filled(
        hintText: 'Search for spots...',
        suffixIcon: Icon(Icons.search, color: Theme.of(context).hintColor),
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
