package com.example.ui.theme

import androidx.compose.ui.graphics.Color

// Blink Brand Palette
val BlinkPink = Color(0xFFE91E63)
val BlinkPinkDeep = Color(0xFFC2185B)
val BlinkGold = Color(0xFFFFCF10)
val BlinkRed = Color(0xFFFF2A3B)
val BlinkBlue = Color(0xFF1A83FA)
val BlinkLavender = Color(0xFFD9A9FB)
val BlinkPurple = Color(0xFF8B5CF6)
val BlinkCyan = Color(0xFF38BDF8)
val BlinkOnlineGreen = Color(0xFF22C55E)
val BlinkAccentSoft = Color(0xFFF9C9DD)

// Dark Theme Colors
val DarkBackground = Color(0xFF0A0A0E)
val DarkSurface = Color(0xFF15141D)
val DarkSurfaceElevated = Color(0xFF1F1D2B)
val DarkBorder = Color(0xFF2E2B3D)
val DarkTextPrimary = Color(0xFFFFFFFF)
val DarkTextSecondary = Color(0xFF9E9AA8)
val DarkTextMuted = Color(0xFF6E6A7A)

// Light Theme Colors
val LightBackground = Color(0xFFF6F8FA)
val LightSurface = Color(0xFFFFFFFF)
val LightSurfaceElevated = Color(0xFFFFFFFF)
val LightBorder = Color(0xFFE2E6EA)
val LightTextPrimary = Color(0xFF11141A)
val LightTextSecondary = Color(0xFF656F7D)
val LightTextMuted = Color(0xFF9BA3AF)

fun getFacultyColor(tag: String?): Color {
    return when (tag?.uppercase()) {
        "SIMME" -> BlinkPink
        "SBMS" -> BlinkCyan
        "LAW" -> BlinkGold
        "ARTS" -> Color(0xFFFF8A65)
        "ENGINEERING" -> Color(0xFF4CAF50)
        "SCIENCE" -> Color(0xFF00BCD4)
        "MEDICINE" -> Color(0xFFE91E63)
        "SOCIAL SCIENCES" -> Color(0xFFFFB74D)
        else -> BlinkPurple
    }
}
