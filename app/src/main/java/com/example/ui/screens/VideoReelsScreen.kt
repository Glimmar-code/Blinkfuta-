package com.example.ui.screens

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.pager.VerticalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.example.data.models.FeedPost
import com.example.ui.components.formatNumber
import com.example.ui.theme.BlinkPink
import com.example.ui.theme.BlinkPurple
import kotlinx.coroutines.delay

@Composable
fun VideoReelsScreen(
    reels: List<FeedPost>,
    isDark: Boolean,
    onLike: (String) -> Unit,
    onComment: (String) -> Unit,
    onBookmark: (String) -> Unit,
    onShare: (String) -> Unit,
    onProfileClick: (String) -> Unit,
    onBackToPosts: () -> Unit
) {
    val pagerState = rememberPagerState(pageCount = { reels.size })
    var selectedFilter by remember { mutableStateOf("Trending") }
    val filters = listOf("Trending", "Campus Life", "Fashion & Style", "Tech Demos", "Aluta Vibes")

    // State for the double tap heart animation
    var showHeartAnimation by remember { mutableStateOf(false) }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
            .testTag("reels_screen")
    ) {
        VerticalPager(
            state = pagerState,
            modifier = Modifier.fillMaxSize()
        ) { page ->
            val reel = reels[page]

            Box(modifier = Modifier
                .fillMaxSize()
                .pointerInput(Unit) {
                    detectTapGestures(
                        onDoubleTap = {
                            if (!reel.isLiked) {
                                onLike(reel.id)
                            }
                            showHeartAnimation = true
                        }
                    )
                }
            ) {
                // Background video image
                AsyncImage(
                    model = reel.images.firstOrNull() ?: "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=1000&fit=crop",
                    contentDescription = "Reel video",
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.fillMaxSize()
                )

                // Top & Bottom gradient overlays for text readability
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(180.dp)
                        .align(Alignment.TopCenter)
                        .background(
                            Brush.verticalGradient(
                                listOf(Color(0xCC000000), Color.Transparent)
                            )
                        )
                )

                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(300.dp)
                        .align(Alignment.BottomCenter)
                        .background(
                            Brush.verticalGradient(
                                listOf(Color.Transparent, Color(0xDD000000))
                            )
                        )
                )

                // Right Engagement Sidebar
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(18.dp),
                    modifier = Modifier
                        .align(Alignment.BottomEnd)
                        .padding(end = 16.dp, bottom = 100.dp)
                ) {
                    // Creator avatar with + button
                    Box(
                        contentAlignment = Alignment.BottomCenter,
                        modifier = Modifier.clickable { onProfileClick(reel.author) }
                    ) {
                        AsyncImage(
                            model = reel.authorAvatar,
                            contentDescription = reel.author,
                            contentScale = ContentScale.Crop,
                            modifier = Modifier
                                .size(48.dp)
                                .clip(CircleShape)
                        )

                        Box(
                            contentAlignment = Alignment.Center,
                            modifier = Modifier
                                .offset(y = 6.dp)
                                .size(20.dp)
                                .clip(CircleShape)
                                .background(BlinkPink)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Add,
                                contentDescription = "Follow",
                                tint = Color.White,
                                modifier = Modifier.size(14.dp)
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(6.dp))

                    // Like
                    ReelActionButton(
                        icon = if (reel.isLiked) Icons.Filled.Favorite else Icons.Outlined.FavoriteBorder,
                        label = formatNumber(reel.likes),
                        tint = if (reel.isLiked) BlinkPink else Color.White,
                        onClick = { onLike(reel.id) }
                    )

                    // Comments
                    ReelActionButton(
                        icon = Icons.Outlined.ChatBubbleOutline,
                        label = formatNumber(reel.commentsCount),
                        tint = Color.White,
                        onClick = { onComment(reel.id) }
                    )

                    // Bookmark
                    ReelActionButton(
                        icon = if (reel.isBookmarked) Icons.Filled.Bookmark else Icons.Outlined.BookmarkBorder,
                        label = "Save",
                        tint = if (reel.isBookmarked) BlinkPurple else Color.White,
                        onClick = { onBookmark(reel.id) }
                    )

                    // Share
                    ReelActionButton(
                        icon = Icons.Outlined.Send,
                        label = "Share",
                        tint = Color.White,
                        onClick = { onShare(reel.id) }
                    )
                }

                // Left Bottom Creator & Caption Info
                Column(
                    modifier = Modifier
                        .align(Alignment.BottomStart)
                        .padding(start = 16.dp, end = 80.dp, bottom = 90.dp)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        modifier = Modifier.clickable { onProfileClick(reel.author) }
                    ) {
                        Text(
                            text = "@${reel.author}",
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )

                        Surface(
                            shape = RoundedCornerShape(100.dp),
                            color = BlinkPink.copy(alpha = 0.8f)
                        ) {
                            Text(
                                text = "Follow",
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Bold,
                                color = Color.White,
                                modifier = Modifier.padding(horizontal = 8.dp, vertical = 2.dp)
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(8.dp))

                    Text(
                        text = reel.text,
                        fontSize = 13.5.sp,
                        color = Color.White.copy(alpha = 0.95f),
                        lineHeight = 18.sp,
                        maxLines = 3
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    // Audio track info
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.MusicNote,
                            contentDescription = "Sound",
                            tint = Color.White,
                            modifier = Modifier.size(16.dp)
                        )
                        Text(
                            text = "Original Sound • ${reel.author} • AfroVibes Lagos 2026",
                            fontSize = 11.sp,
                            color = Color.White.copy(alpha = 0.8f)
                        )
                    }
                }

                // Heart animation overlay
                if (showHeartAnimation) {
                    val scale by animateFloatAsState(
                        targetValue = if (showHeartAnimation) 1.5f else 0f,
                        animationSpec = spring(
                            dampingRatio = Spring.DampingRatioMediumBouncy,
                            stiffness = Spring.StiffnessLow
                        ),
                        label = "heart_scale"
                    )
                    val alpha by animateFloatAsState(
                        targetValue = if (showHeartAnimation) 0f else 1f,
                        animationSpec = tween(durationMillis = 1000, delayMillis = 500),
                        label = "heart_alpha"
                    )

                    LaunchedEffect(showHeartAnimation) {
                        if (showHeartAnimation) {
                            delay(1200)
                            showHeartAnimation = false
                        }
                    }

                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Filled.Favorite,
                            contentDescription = "Liked",
                            tint = BlinkPink.copy(alpha = alpha),
                            modifier = Modifier
                                .size(100.dp)
                                .scale(scale)
                        )
                    }
                }
            }
        }

        // Top Filter Bar & Back button
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 44.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp)
            ) {
                IconButton(
                    onClick = onBackToPosts,
                    modifier = Modifier
                        .size(36.dp)
                        .background(Color(0x66000000), CircleShape)
                ) {
                    Icon(
                        imageVector = Icons.Default.ArrowBack,
                        contentDescription = "Back to Feed",
                        tint = Color.White,
                        modifier = Modifier.size(20.dp)
                    )
                }

                Spacer(modifier = Modifier.width(12.dp))

                Text(
                    text = "Blink Reels ✦",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            LazyRow(
                contentPadding = PaddingValues(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(filters) { filter ->
                    val selected = selectedFilter == filter
                    Surface(
                        shape = RoundedCornerShape(100.dp),
                        color = if (selected) Color.White else Color(0x33000000),
                        modifier = Modifier.clickable { selectedFilter = filter }
                    ) {
                        Text(
                            text = filter,
                            fontSize = 12.sp,
                            fontWeight = if (selected) FontWeight.Bold else FontWeight.Normal,
                            color = if (selected) Color.Black else Color.White,
                            modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp)
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun ReelActionButton(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    label: String,
    tint: Color,
    onClick: () -> Unit
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.clickable { onClick() }
    ) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier
                .size(44.dp)
                .clip(CircleShape)
                .background(Color(0x33000000))
        ) {
            Icon(
                imageVector = icon,
                contentDescription = label,
                tint = tint,
                modifier = Modifier.size(24.dp)
            )
        }

        Spacer(modifier = Modifier.height(4.dp))

        Text(
            text = label,
            fontSize = 11.5.sp,
            fontWeight = FontWeight.SemiBold,
            color = Color.White
        )
    }
}
