import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:myspace/controllers/navigation_controller.dart';
import 'widget_updater.dart';

class WidgetLaunchBridge {
  static const MethodChannel _channel =
      MethodChannel('com.myspace.app/widget_events');

  static bool _configured = false;

  static void configure() {
    if (_configured) return;
    _configured = true;
    _channel.setMethodCallHandler(_handleCall);
  }

  static Future<void> _handleCall(MethodCall call) async {
    if (call.method != 'widgetClicked') return;

    try {
      if (Get.isRegistered<NavigationController>()) {
        Get.find<NavigationController>().changePage(2);
      }
      await HeatmapWidgetUpdater.updateHeatmap();
    } catch (_) {
      
    }
  }
}