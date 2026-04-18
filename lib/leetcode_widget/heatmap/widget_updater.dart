import 'dart:io';
import 'package:home_widget/home_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'heatmap_painter.dart';
import '../leetcode/leetcode_heatmap_service.dart';

class HeatmapWidgetUpdater {
  static const String androidProviderName = 'HeatmapHomeWidgetProvider';
  static const String androidReceiverName = 'HeatmapHomeWidgetProvider';

  static Future<void> updateHeatmap({String username = 'pritam_doesLC'}) async {
    final service = LeetCodeHeatmapService();
    final values = await service.fetchYearHeatmapBuckets(username: username);
    await updateAndroidWidgetFromHardcodedData(values: values);
  }

  static Future<Map<String, int>> getLatestHeatmapData() async {
    final service = LeetCodeHeatmapService();
    return service.fetchYearHeatmapBuckets(username: 'pritam_doesLC');
  }

  static Future<void> updateAndroidWidgetFromHardcodedData({
    required Map<String, int> values,
  }) async {
    await updateAndroidWidgetWithSize(
      values: values,
      widthPx: 900,
      heightPx: 400,
    );
  }

  static Future<void> updateAndroidWidgetWithSize({
    required Map<String, int> values,
    required int widthPx,
    required int heightPx,
  }) async {
    final bytes = await YearHeatmapRenderer.renderPng(
      values: values,
      endDateInclusive: DateTime.now(),
      imageWidthPx: widthPx,
      imageHeightPx: heightPx,
    );

    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/heatmap_widget.png');
    await file.writeAsBytes(bytes, flush: true);

    await HomeWidget.saveWidgetData<String>('heatmap_path', file.path);

    await HomeWidget.updateWidget(
      name: androidProviderName,
      androidName: androidReceiverName,
    );
  }
}
