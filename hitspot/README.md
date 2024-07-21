# hitspot

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Melos

Melos is a tool designed to manage Dart and Flutter projects with multiple packages. It will get all dependencies in our packages, without having to enter them and run ```flutter pub get``` inside. 

#### How to use

1. Install Melos
```dart
dart pub global activate melos
flutter pub add melos
```
2. Check if melos.yaml exists, if not create it and add following:
```
name: hitspot

packages:
  - packages/**
```
3. Run ```melos bootstrap```