package com.myspace.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.os.Bundle
import android.util.DisplayMetrics
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import android.net.Uri
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class HeatmapHomeWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            renderFromSavedPath(context, appWidgetManager, widgetId, widgetData)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)

        val wDp = newOptions.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH)
        val hDp = newOptions.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT)

        val (wPx, hPx) = dpToPx(context, wDp, hDp)

        val prefs = HomeWidgetPlugin.getData(context)
        prefs.edit()
            .putInt("render_w_px", wPx)
            .putInt("render_h_px", hPx)
            .apply()
    }

    private fun renderFromSavedPath(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        widgetData: android.content.SharedPreferences
    ) {
        val views = RemoteViews(context.packageName, R.layout.heatmap_widget)

        val launchIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("myspace://widget?source=heatmap")
        )
        views.setOnClickPendingIntent(R.id.root, launchIntent)

        val path = widgetData.getString("heatmap_path", null)
        if (!path.isNullOrBlank()) {
            val bitmap = BitmapFactory.decodeFile(path)
            if (bitmap != null) {
                views.setImageViewBitmap(R.id.heatmapImage, bitmap)
            }
        }

        appWidgetManager.updateAppWidget(widgetId, views)
    }

    private fun dpToPx(context: Context, wDp: Int, hDp: Int): Pair<Int, Int> {
        val dm: DisplayMetrics = context.resources.displayMetrics
        val wPx = (wDp * dm.density * 2f).toInt().coerceIn(200, 2200)
        val hPx = (hDp * dm.density * 2f).toInt().coerceIn(100, 2200)
        return Pair(wPx, hPx)
    }
}
