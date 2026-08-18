package com.example.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color

private val DarkColorScheme = darkColorScheme(
    primary = BlinkPink,
    onPrimary = Color.White,
    primaryContainer = BlinkPinkDeep,
    onPrimaryContainer = Color.White,
    secondary = BlinkPurple,
    onSecondary = Color.White,
    secondaryContainer = Color(0xFF2D1B4E),
    onSecondaryContainer = BlinkLavender,
    tertiary = BlinkCyan,
    background = DarkBackground,
    onBackground = DarkTextPrimary,
    surface = DarkSurface,
    onSurface = DarkTextPrimary,
    surfaceVariant = DarkSurfaceElevated,
    onSurfaceVariant = DarkTextSecondary,
    outline = DarkBorder,
    outlineVariant = Color(0x33FFFFFF),
    error = BlinkRed,
    onError = Color.White
)

private val LightColorScheme = lightColorScheme(
    primary = BlinkPink,
    onPrimary = Color.White,
    primaryContainer = BlinkAccentSoft,
    onPrimaryContainer = BlinkPinkDeep,
    secondary = BlinkPurple,
    onSecondary = Color.White,
    secondaryContainer = Color(0xFFF3E8FF),
    onSecondaryContainer = BlinkPurple,
    tertiary = BlinkCyan,
    background = LightBackground,
    onBackground = LightTextPrimary,
    surface = LightSurface,
    onSurface = LightTextPrimary,
    surfaceVariant = LightSurfaceElevated,
    onSurfaceVariant = LightTextSecondary,
    outline = LightBorder,
    outlineVariant = Color(0x1F000000),
    error = BlinkRed,
    onError = Color.White
)

fun blinkBackgroundBrush(isDark: Boolean): Brush {
    return if (isDark) {
        Brush.radialGradient(
            colors = listOf(
                Color(0xFF22112E),
                Color(0xFF0F0B17),
                DarkBackground
            ),
            radius = 1200f
        )
    } else {
        Brush.radialGradient(
            colors = listOf(
                Color(0xFFFDEEF4),
                Color(0xFFF3F5FA),
                LightBackground
            ),
            radius = 1200f
        )
    }
}

@Composable
fun BlinkTheme(
    darkTheme: Boolean = true,
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}
