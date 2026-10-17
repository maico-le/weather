package com.maico.weather

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import org.json.JSONObject

class WeatherAppWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.weather_app_widget)

            // Read latest weather data from SharedPreferences
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val jsonStr = prefs.getString("flutter.flutter.weather_widget_data", null)
                ?: prefs.getString("flutter.weather_widget_data", null)

            if (!jsonStr.isNullOrEmpty()) {
                try {
                    val json = JSONObject(jsonStr)
                    views.setTextViewText(R.id.widget_city, json.optString("city", "Ho Chi Minh City"))
                    views.setTextViewText(R.id.widget_temp, json.optString("temp", "30°"))
                    views.setTextViewText(R.id.widget_desc, json.optString("desc", "Clear Sky"))
                    val humidity = json.optString("humidity", "70%")
                    val wind = json.optString("wind", "10 km/h")
                    views.setTextViewText(R.id.widget_sub, "💧 $humidity  •  💨 $wind")
                    val advice = json.optString("aiAdvice", "Thời tiết mát mẻ, thích hợp cho các hoạt động ngoài trời.")
                    views.setTextViewText(R.id.widget_ai_advice, advice)
                } catch (e: Exception) {
                    // Fallback to defaults
                }
            }

            // Click to launch main app
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, WeatherAppWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            for (appWidgetId in appWidgetIds) {
                updateAppWidget(context, appWidgetManager, appWidgetId)
            }
        }
    }
}
