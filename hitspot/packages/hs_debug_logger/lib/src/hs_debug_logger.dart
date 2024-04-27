import "dart:developer" as developer;

class HSDebugLogger {
  static void logInfo(String msg) {
    developer.log("\x1B[34m[INFO] $msg\x1B[0m", name: "SNDebugger");
  }

  static void logSuccess(String msg) {
    developer.log("\x1B[32m[SUCCESS] $msg\x1B[0m", name: "SNDebugger");
  }

  static void logWarning(String msg) {
    developer.log("\x1B[33m[WARNING] $msg\x1B[0m", name: "SNDebugger");
  }

  static void logError(String msg) {
    developer.log("\x1B[31m[ERROR] $msg\x1B[0m", name: "SNDebugger");
  }
}
