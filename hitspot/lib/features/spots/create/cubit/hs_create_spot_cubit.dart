// import 'dart:io';
// import 'dart:isolate';
// import 'dart:ui';

// import 'package:equatable/equatable.dart';
// import 'package:exif/exif.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:hitspot/constants/constants.dart';
// import 'package:hitspot/features/spots/create/cubit/hs_spot_creation_data.dart';
// import 'package:hitspot/features/spots/create/cubit/hs_spot_upload_cubit.dart';
// import 'package:hitspot/features/spots/create/map/view/choose_location_provider.dart';
// import 'package:hitspot/main.dart';
// import 'package:hitspot/widgets/hs_scaffold.dart';
// import 'package:hs_database_repository/hs_database_repository.dart';
// import 'package:hs_debug_logger/hs_debug_logger.dart';
// import 'package:hs_location_repository/hs_location_repository.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:image/image.dart' as img;

// part 'hs_create_spot_state.dart';

// class HSCreateSpotCubit extends Cubit<HSCreateSpotState> {
//   HSCreateSpotCubit({this.prototype}) : super(const HSCreateSpotState()) {
//     _init();
//   }

//   void _init() async {
//     try {
//       await chooseImages();
//       await chooseLocation();
//       if (prototype != null) {
//         emit(
//           state.copyWith(
//             title: prototype!.title,
//             description: prototype!.description,
//           ),
//         );
//       }
//       emit(state.copyWith(status: HSCreateSpotStatus.fillingData));
//     } catch (e) {
//       HSDebugLogger.logInfo("Error creating spots: $e");
//       emit(state.copyWith(status: HSCreateSpotStatus.error));
//     }
//   }

//   List<File> get _xfilesToFiles =>
//       state.images.map((e) => File(e.path)).toList();
// }
