import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/spots/create_2/create_spot_error_page.dart';
import 'package:hitspot/features/spots/create_2/images/cubit/hs_create_spot_images_cubit.dart';
import 'package:hitspot/widgets/form/hs_form.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:reorderable_grid/reorderable_grid.dart';

class CreateSpotImagesPage extends StatelessWidget {
  const CreateSpotImagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HsCreateSpotImagesCubit>();
    return HSScaffold(
      appBar: HSAppBar(
        titleText: "Add photos",
        enableDefaultBackButton: true,
      ),
      body: BlocSelector<HsCreateSpotImagesCubit, HsCreateSpotImagesState,
          HsCreateSpotImagesStatus>(
        selector: (state) => state.status,
        builder: (context, status) {
          if (status == HsCreateSpotImagesStatus.error) {
            return const CreateSpotErrorPage(HSCreateSpotErrorType.photos);
          }
          return BlocBuilder<HsCreateSpotImagesCubit, HsCreateSpotImagesState>(
            builder: (context, state) {
              if (state.images.isEmpty && state.imageUrls.isEmpty) {
                return const HSLoadingIndicator();
              }
              return Column(
                children: [
                  ReorderableGridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    children: [
                      ...state.images.map((xFile) => _ImageTile(
                          key: ValueKey(xFile.path),
                          imagePath: xFile.path,
                          index: state.images.indexOf(xFile),
                          type: _ImageTileType.asset)),
                      ...state.imageUrls.map((url) => _ImageTile(
                          key: ValueKey(url),
                          index: state.imageUrls.indexOf(url),
                          type: _ImageTileType.network,
                          imagePath: url)),
                    ],
                    onReorder: (oldIndex, newIndex) {
                      context
                          .read<HsCreateSpotImagesCubit>()
                          .reorderImages(oldIndex, newIndex);
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Drag and drop to reorder",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  HSFormButtonsRow(
                    left: HSFormButton(
                        onPressed: cubit.chooseImages,
                        child: const Text("Select photos")),
                    right: HSFormButton(
                        onPressed: cubit.next, child: const Text("Next")),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}

enum _ImageTileType { asset, network }

class _ImageTile extends StatelessWidget {
  const _ImageTile(
      {super.key,
      required this.type,
      required this.imagePath,
      required this.index});

  final _ImageTileType type;
  final String imagePath;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: type == _ImageTileType.asset
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: imagePath,
                    fit: BoxFit.cover,
                    imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    placeholder: (context, url) =>
                        const HSShimmerBox(width: 60.0, height: 60.0),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error)),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
