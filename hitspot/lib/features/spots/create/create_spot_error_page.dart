import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';

enum HSCreateSpotErrorType {
  location,
  photos,
  unknown,
}

class CreateSpotErrorPage extends StatelessWidget {
  const CreateSpotErrorPage(this.errorType, {super.key});

  final HSCreateSpotErrorType errorType;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _getErrorIcon(errorType),
          Text(
            _getErrorTitle(errorType),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 16),
          Text(
            _getErrorMessage(errorType),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.hintify,
          ),
          const SizedBox(height: 16),
          _getErrorButton(errorType),
        ],
      ),
    );
  }

  Icon _getErrorIcon(HSCreateSpotErrorType errorType) {
    switch (errorType) {
      case HSCreateSpotErrorType.location:
        return const Icon(Icons.location_off, size: 72);
      case HSCreateSpotErrorType.photos:
        return const Icon(Icons.photo, size: 72);
      case HSCreateSpotErrorType.unknown:
      default:
        return const Icon(Icons.error, size: 72);
    }
  }

  String _getErrorTitle(HSCreateSpotErrorType errorType) {
    switch (errorType) {
      case HSCreateSpotErrorType.location:
        return 'Location Permission Denied';
      case HSCreateSpotErrorType.photos:
        return 'Photos Permission Denied';
      case HSCreateSpotErrorType.unknown:
      default:
        return 'Unknown Error';
    }
  }

  String _getErrorMessage(HSCreateSpotErrorType errorType) {
    switch (errorType) {
      case HSCreateSpotErrorType.location:
        return 'Location permission is denied. Please enable it in the settings.';
      case HSCreateSpotErrorType.photos:
        return 'Photos permission is denied. Please enable it in the settings by clicking on the button below.';
      case HSCreateSpotErrorType.unknown:
      default:
        return 'An unknown error occurred. Please try again.';
    }
  }

  CupertinoButton _getErrorButton(HSCreateSpotErrorType errorType) {
    late final String buttonText;
    late final VoidCallback onPressed;
    if (errorType == HSCreateSpotErrorType.photos) {
      onPressed = () => AppSettings.openAppSettings();
      buttonText = 'Open Photos Settings';
    } else if (errorType == HSCreateSpotErrorType.location) {
      onPressed = () => AppSettings.openAppSettings();
      buttonText = 'Open Location Settings';
    } else {
      onPressed = () => navi.pop();
      buttonText = 'Try Again';
    }
    return CupertinoButton(
      color: app.theme.mainColor,
      onPressed: onPressed,
      child: Text(buttonText),
    );
  }
}
