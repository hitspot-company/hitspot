import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class HSPickers {
  // SINGLETON
  HSPickers._internal();
  static final HSPickers _instance = HSPickers._internal();
  static HSPickers get instance => _instance;

  DateTime get now => DateTime.now();
  DateTime get minAge => DateTime(now.year - 16, now.month, now.day);
  DateTime get maxAge => DateTime(now.year - 100, now.month, now.day);

  Future<DateTime?> date(
      {DateTime? initialDate,
      DateTime? currentDate,
      DateTime? firstDate,
      DateTime? lastDate}) async {
    DateTime? pickedDate;
    DateTime now = DateTime.now();
    pickedDate = await showDatePicker(
        context: app.context,
        currentDate: currentDate ?? now,
        firstDate: firstDate ?? now,
        lastDate: lastDate ?? DateTime(now.year + 50, now.month, now.day));
    return (pickedDate);
  }

  Future<Color?> color([Color? previousColor]) async {
    Color? pickedColor;

    await ColorPicker(
      color: previousColor ?? appTheme.mainColor,
      onColorChanged: (Color color) => pickedColor = color,
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: const Text(
        'Select color',
        // style: textTheme.titleSmall,
      ),
      subheading: const Text(
        'Select color shade',
        // style: textTheme.titleSmall,
      ),
      wheelSubheading: const Text(
        'Selected color and its shades',
        // style: textTheme.titleSmall,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      // materialNameTextStyle: textTheme.bodySmall,
      // colorNameTextStyle: textTheme.bodySmall,
      // colorCodeTextStyle: textTheme.bodySmall,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
    ).showPickerDialog(
      app.context!,
      surfaceTintColor: Colors.transparent,
      transitionBuilder: (BuildContext context, Animation<double> a1,
          Animation<double> a2, Widget widget) {
        final double curvedValue =
            Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: widget,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      constraints:
          const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),
    );

    return (pickedColor);
  }

  Future<List<XFile>> multipleImages({
    CropAspectRatio? cropAspectRatio,
  }) async {
    try {
      final picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(imageQuality: 80);
      if (images.isEmpty) throw "No images selected";
      return images;
    } catch (e) {
      HSDebugLogger.logError(e.toString());
      rethrow;
    }
  }

  Future<CroppedFile?> image(
      {bool crop = true,
      bool value = true,
      CropAspectRatio? cropAspectRatio,
      CropStyle? cropStyle}) async {
    try {
      late final CroppedFile? file;
      if (!value) return null;
      final picker = ImagePicker();
      final XFile? image =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image == null) return null;
      if (!crop) {
        file = CroppedFile(image.path);
        return file;
      }
      file = await _getCroppedFile(image.path,
          cropAspectRatio: cropAspectRatio, cropStyle: cropStyle);
      if (file == null) return null;
      return file;
    } catch (e) {
      HSDebugLogger.logError(e.toString());
      return null;
    }
  }

  Future<CroppedFile?> _getCroppedFile(String sourcePath,
      {CropAspectRatio? cropAspectRatio, CropStyle? cropStyle}) async {
    late final CroppedFile? ret;
    final ImageCropper cropper = ImageCropper();
    ret = await cropper.cropImage(
      aspectRatio: cropAspectRatio,
      // cropStyle: cropStyle ?? CropStyle.rectangle,
      sourcePath: sourcePath,
      uiSettings: [
        IOSUiSettings(
          title: 'Board Image',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    return ret;
  }
}
