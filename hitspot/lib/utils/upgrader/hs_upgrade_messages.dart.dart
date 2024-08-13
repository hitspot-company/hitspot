import 'package:upgrader/upgrader.dart';

class HSUpgradeMessages extends UpgraderMessages {
  /// Override the message function to provide custom language localization.
  @override
  String message(UpgraderMessage messageKey) {
    switch (languageCode) {
      case 'en': // English
        return _EnglishMessages().message(messageKey);
      case 'pl':
        return _PolishMessages().message(messageKey);
      default:
        return super.message(messageKey)!;
    }
  }
}

class _EnglishMessages extends UpgraderMessages {
  @override
  String message(UpgraderMessage messageKey) {
    if (languageCode == 'en') {
      switch (messageKey) {
        case UpgraderMessage.body:
          return 'New version of {{appName}} has been released!\nInstalled: {{currentInstalledVersion}}\nAvailable: {{currentAppStoreVersion}}';
        case UpgraderMessage.buttonTitleIgnore:
          return 'Ignore';
        case UpgraderMessage.buttonTitleLater:
          return 'Later';
        case UpgraderMessage.buttonTitleUpdate:
          return 'Update Now';
        case UpgraderMessage.prompt:
          return 'Do you Want to update?';
        case UpgraderMessage.releaseNotes:
          return 'Release Notes';
        case UpgraderMessage.title:
          return 'Update App?';
        default:
          return super.message(messageKey)!;
      }
    }
    return super.message(messageKey)!;
  }
}

class _PolishMessages extends UpgraderMessages {
  @override
  String message(UpgraderMessage messageKey) {
    if (languageCode == 'pl') {
      switch (messageKey) {
        case UpgraderMessage.body:
          return 'Nowa wersja aplikacji {{appName}}\nZainstalowana: {{currentInstalledVersion}}\nDostępna: {{currentAppStoreVersion}}';
        case UpgraderMessage.buttonTitleIgnore:
          return 'Ignoruj';
        case UpgraderMessage.buttonTitleLater:
          return 'Później';
        case UpgraderMessage.buttonTitleUpdate:
          return 'Zaktualizuj teraz';
        case UpgraderMessage.prompt:
          return 'Czy chcesz zaktualizować aplikację?';
        case UpgraderMessage.releaseNotes:
          return 'Informacje o aktualizacji';
        case UpgraderMessage.title:
          return 'Zaktualizować aplikację?';
        default:
          return super.message(messageKey)!;
      }
    }
    return super.message(messageKey)!;
  }
}
