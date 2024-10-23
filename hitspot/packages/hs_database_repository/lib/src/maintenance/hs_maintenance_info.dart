class HSMaintenanceInfo {
  final String? newestVersion, minVersion, currentVersion;
  final bool isUnderMaintenance;

  const HSMaintenanceInfo({
    this.newestVersion,
    this.minVersion,
    this.currentVersion,
    required this.isUnderMaintenance,
  });

  factory HSMaintenanceInfo.underMaintenance() {
    return const HSMaintenanceInfo(isUnderMaintenance: true);
  }
}
