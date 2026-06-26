import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
class ProgressHelper {

  static Future<void> submitPhase({
    required ActivityResponse activity,
    required bool usedHint,
  }) async {

    try {

      print(" SUBMIT PHASE STARTED");
      print("PhaseId: ${activity.phaseId}");
      print("UsedHint: $usedHint");

      final result = await ApiManager.logAttemptStatus(
        phaseId: activity.phaseId!,
        userHint: usedHint,
      );

      print(" RESULT FROM API: $result");

      if (result == null) {
        print(" API RETURNED NULL");
      } else {
        print(" IS PASSED: ${result.isPassed}");
        print(" POINTS: ${result.points}");
      }

    } catch (e) {
      print(" ERROR IN SUBMIT PHASE: $e");
    }
  }
}