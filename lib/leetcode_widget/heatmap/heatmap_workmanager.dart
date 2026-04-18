import 'package:workmanager/workmanager.dart';
import 'widget_updater.dart';

const String heatmapRefreshTaskName = 'heatmap_refresh_task';
const String heatmapRefreshUniqueName = 'heatmap_refresh_unique';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      if (taskName == heatmapRefreshTaskName) {
        await HeatmapWidgetUpdater.updateHeatmap();
      }
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}

class HeatmapWorkmanager {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

    await Workmanager().registerPeriodicTask(
      heatmapRefreshUniqueName,
      heatmapRefreshTaskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}
