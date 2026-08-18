package com.example.notification

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import com.example.MainActivity
import com.example.R

object BlinkNotificationHelper {

    const val CHANNEL_MESSAGES = "blink_messages_channel"
    const val CHANNEL_SOCIAL = "blink_social_channel"
    const val CHANNEL_MARKET = "blink_market_channel"

    private const val NOTIFICATION_ID_BASE_MSG = 1000
    private const val NOTIFICATION_ID_BASE_SOCIAL = 2000
    private const val NOTIFICATION_ID_BASE_MARKET = 3000

    fun createNotificationChannels(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager ?: return

            // Channel 1: Direct Messages
            val messagesChannel = NotificationChannel(
                CHANNEL_MESSAGES,
                "Blink Direct Messages",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Incoming chat messages from campus students & sellers"
                enableLights(true)
                lightColor = Color.parseColor("#E02B6D")
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 200, 100, 200)
                setShowBadge(true)
            }

            // Channel 2: Social Activity & Posts
            val socialChannel = NotificationChannel(
                CHANNEL_SOCIAL,
                "Blink Campus Activity",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Likes, comments, mentions, and campus trending reels"
                enableLights(true)
                lightColor = Color.parseColor("#8A2BE2")
                enableVibration(true)
                setShowBadge(true)
            }

            // Channel 3: Aluta Marketplace
            val marketChannel = NotificationChannel(
                CHANNEL_MARKET,
                "Aluta Market Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Buyer inquiries, flash sales, and product deals"
                enableLights(true)
                lightColor = Color.parseColor("#FFB800")
                enableVibration(true)
                setShowBadge(true)
            }

            notificationManager.createNotificationChannel(messagesChannel)
            notificationManager.createNotificationChannel(socialChannel)
            notificationManager.createNotificationChannel(marketChannel)
        }
    }

    fun hasNotificationPermission(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            NotificationManagerCompat.from(context).areNotificationsEnabled()
        }
    }

    fun showChatMessageNotification(
        context: Context,
        senderUsername: String,
        senderName: String,
        messageText: String
    ) {
        if (!hasNotificationPermission(context)) return

        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("EXTRA_ACTION", "OPEN_CHAT")
            putExtra("EXTRA_PARTNER_USERNAME", senderUsername)
            putExtra("EXTRA_PARTNER_NAME", senderName)
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            senderUsername.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_MESSAGES)
            .setSmallIcon(android.R.drawable.ic_dialog_email)
            .setContentTitle("💬 $senderName (@$senderUsername)")
            .setContentText(messageText)
            .setStyle(NotificationCompat.BigTextStyle().bigText(messageText))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_MESSAGE)
            .setColor(0xFFE02B6D.toInt())
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setVibrate(longArrayOf(0, 250, 150, 250))
            .build()

        val notificationId = NOTIFICATION_ID_BASE_MSG + (senderUsername.hashCode() % 500)
        try {
            NotificationManagerCompat.from(context).notify(notificationId, notification)
        } catch (_: SecurityException) {}
    }

    fun showSocialNotification(
        context: Context,
        title: String,
        body: String,
        targetPostId: String? = null
    ) {
        if (!hasNotificationPermission(context)) return

        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("EXTRA_ACTION", "OPEN_POST")
            putExtra("EXTRA_POST_ID", targetPostId)
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            (title + body).hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_SOCIAL)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setCategory(NotificationCompat.CATEGORY_SOCIAL)
            .setColor(0xFF8A2BE2.toInt())
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        val notificationId = NOTIFICATION_ID_BASE_SOCIAL + ((title + body).hashCode() % 500)
        try {
            NotificationManagerCompat.from(context).notify(notificationId, notification)
        } catch (_: SecurityException) {}
    }

    fun showMarketNotification(
        context: Context,
        title: String,
        body: String,
        targetMarketId: String? = null
    ) {
        if (!hasNotificationPermission(context)) return

        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("EXTRA_ACTION", "OPEN_MARKET")
            putExtra("EXTRA_MARKET_ID", targetMarketId)
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            (title + body).hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_MARKET)
            .setSmallIcon(android.R.drawable.ic_menu_agenda)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_EVENT)
            .setColor(0xFFFFB800.toInt())
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        val notificationId = NOTIFICATION_ID_BASE_MARKET + ((title + body).hashCode() % 500)
        try {
            NotificationManagerCompat.from(context).notify(notificationId, notification)
        } catch (_: SecurityException) {}
    }
}
