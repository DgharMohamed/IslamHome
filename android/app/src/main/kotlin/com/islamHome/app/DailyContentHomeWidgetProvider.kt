package com.islamHome.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class DailyContentHomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { appWidgetId ->
            val views = RemoteViews(context.packageName, R.layout.daily_content_home_widget)

            val title = widgetData.getString("daily_widget_title", "Daily Inspiration")
            val content = widgetData.getString("daily_widget_content", "")
            val subtitle = widgetData.getString("daily_widget_subtitle", "")
            val type = widgetData.getString("daily_widget_type", "verse")

            views.setTextViewText(R.id.daily_widget_title, title)
            views.setTextViewText(R.id.daily_widget_content, content)
            views.setTextViewText(R.id.daily_widget_subtitle, subtitle)

            val iconRes = when (type) {
                "hadith" -> R.drawable.ic_daily_widget_quote
                "adhkar" -> R.drawable.ic_daily_widget_favorite
                else -> R.drawable.ic_daily_widget_star
            }
            views.setImageViewResource(R.id.daily_widget_icon, iconRes)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
