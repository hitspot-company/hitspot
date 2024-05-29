import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';

class HSPickers {
  // SINGLETON
  HSPickers._internal();
  static final HSPickers _instance = HSPickers._internal();
  static HSPickers get instance => _instance;

  Future<DateTime?> date(
      [DateTime? initialDate,
      DateTime? currentDate,
      DateTime? firstDate,
      DateTime? lastDate]) async {
    DateTime? pickedDate;
    DateTime now = DateTime.now();
    pickedDate = await showDatePicker(
        context: app.context!,
        currentDate: currentDate ?? now,
        firstDate: firstDate ?? now,
        lastDate: lastDate ?? DateTime(now.year + 50, now.month, now.day));
    return (pickedDate);
  }

  Future<Color?> pickColor([Color? previousColor]) async {
    Color? pickedColor;

    await ColorPicker(
      color: previousColor ?? currentTheme.mainColor,
      onColorChanged: (Color color) => pickedColor = color,
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: Text(
        'Select color',
        style: textTheme.titleSmall,
      ),
      subheading: Text(
        'Select color shade',
        style: textTheme.titleSmall,
      ),
      wheelSubheading: Text(
        'Selected color and its shades',
        style: textTheme.titleSmall,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      materialNameTextStyle: textTheme.bodySmall,
      colorNameTextStyle: textTheme.bodySmall,
      colorCodeTextStyle: textTheme.bodySmall,
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
}
