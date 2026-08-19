package com.example.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.example.data.models.FeedPost
import com.example.data.models.VerificationBadge
import com.example.ui.theme.BlinkPink
import com.example.ui.theme.BlinkPurple

@Composable
fun PostCard(
    post: FeedPost,
    isDark: Boolean,
    onLike: () -> Unit,
    onComment: () -> Unit,
    onBookmark: () -> Unit,
    onShare: () -> Unit,
    onOptionsClick: () -> Unit,
    onProfileClick: (String) -> Unit,
    onViewed: () -> Unit = {},
    modifier: Modifier = Modifier
) {
    LaunchedEffect(post.id) {
        onViewed()
    }

    val cardBg = if (isDark) MaterialTheme.colorScheme.surface else Color.White

    Card(
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = cardBg),
        elevation = CardDefaults.cardElevation(defaultElevation = if (isDark) 0.dp else 1.dp),
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 6.dp)
            .testTag("post_card_${post.id}")
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            // Author header
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    modifier = Modifier.clickable { onProfileClick(post.author) }
                ) {
                    AsyncImage(
                        model = post.authorAvatar,
                        contentDescription = post.author,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier
                            .size(42.dp)
                            .clip(CircleShape)
                    )

                    Column {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            Text(
                                text = post.author,
                                style = MaterialTheme.typography.titleMedium.copy(
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 14.sp
                                ),
                                color = MaterialTheme.colorScheme.onSurface
                            )

                            if (post.isVerified) {
                                VerifiedMark(badge = VerificationBadge.BLUE, size = 14.dp)
                            }

                            FacultyBadge(tag = post.facultyTag)
                        }

                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            Text(
                                text = post.timeAgo,
                                style = MaterialTheme.typography.bodySmall.copy(
                                    fontSize = 11.sp,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            )

                            Text(
                                text = "•",
                                fontSize = 10.sp,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )

                            // Views indicator
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(3.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Outlined.Visibility,
                                    contentDescription = "Views",
                                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                                    modifier = Modifier.size(12.dp)
                                )
                                Text(
                                    text = "${formatNumber(post.viewsCount)} views",
                                    style = MaterialTheme.typography.bodySmall.copy(
                                        fontSize = 11.sp,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                )
                            }
                        }
                    }
                }

                // 3-Dots Options Menu
                IconButton(
                    onClick = onOptionsClick,
                    modifier = Modifier.size(34.dp).testTag("post_options_${post.id}")
                ) {
                    Icon(
                        imageVector = Icons.Default.MoreHoriz,
                        contentDescription = "Post Options",
                        tint = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.size(22.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Post content text with highlighted hashtags and mentions
            HighlightedText(
                text = post.text,
                accentColor = BlinkPink,
                textColor = MaterialTheme.colorScheme.onSurface
            )

            // Post Images
            if (post.images.isNotEmpty()) {
                Spacer(modifier = Modifier.height(12.dp))
                if (post.images.size == 1) {
                    AsyncImage(
                        model = post.images[0],
                        contentDescription = "Post image",
                        contentScale = ContentScale.Crop,
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(240.dp)
                            .clip(RoundedCornerShape(16.dp))
                    )
                } else {
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        post.images.take(2).forEach { img ->
                            AsyncImage(
                                model = img,
                                contentDescription = "Post image",
                                contentScale = ContentScale.Crop,
                                modifier = Modifier
                                    .weight(1f)
                                    .height(180.dp)
                                    .clip(RoundedCornerShape(14.dp))
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(14.dp))

            // Action Row: Like, Comment, Share, Bookmark
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(18.dp)
                ) {
                    // Like button
                    val likeScale by animateFloatAsState(
                        targetValue = if (post.isLiked) 1.25f else 1f,
                        animationSpec = spring(dampingRatio = 0.4f),
                        label = "likeScale"
                    )
                    val likeColor by animateColorAsState(
                        targetValue = if (post.isLiked) BlinkPink else MaterialTheme.colorScheme.onSurfaceVariant,
                        label = "likeColor"
                    )

                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp),
                        modifier = Modifier
                            .clickable { onLike() }
                            .padding(vertical = 4.dp)
                            .testTag("like_button_${post.id}")
                    ) {
                        Icon(
                            imageVector = if (post.isLiked) Icons.Filled.Favorite else Icons.Outlined.FavoriteBorder,
                            contentDescription = "Like",
                            tint = likeColor,
                            modifier = Modifier
                                .size(22.dp)
                                .scale(likeScale)
                        )
                        Text(
                            text = formatNumber(post.likes),
                            fontSize = 12.5.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = likeColor
                        )
                    }

                    // Comment button
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp),
                        modifier = Modifier
                            .clickable { onComment() }
                            .padding(vertical = 4.dp)
                            .testTag("comment_button_${post.id}")
                    ) {
                        Icon(
                            imageVector = Icons.Outlined.ChatBubbleOutline,
                            contentDescription = "Comments",
                            tint = MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier = Modifier.size(20.dp)
                        )
                        Text(
                            text = formatNumber(post.commentsCount),
                            fontSize = 12.5.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }

                    // Share button
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp),
                        modifier = Modifier
                            .clickable { onShare() }
                            .padding(vertical = 4.dp)
                            .testTag("share_button_${post.id}")
                    ) {
                        Icon(
                            imageVector = Icons.Outlined.Send,
                            contentDescription = "Share",
                            tint = MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier = Modifier.size(20.dp)
                        )
                        Text(
                            text = formatNumber(post.sharesCount),
                            fontSize = 12.5.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }

                // Bookmark / Save icon
                val bookmarkScale by animateFloatAsState(
                    targetValue = if (post.isBookmarked) 1.2f else 1f,
                    animationSpec = spring(dampingRatio = 0.45f),
                    label = "bookmarkScale"
                )

                IconButton(
                    onClick = onBookmark,
                    modifier = Modifier.size(32.dp).testTag("bookmark_button_${post.id}")
                ) {
                    Icon(
                        imageVector = if (post.isBookmarked) Icons.Filled.Bookmark else Icons.Outlined.BookmarkBorder,
                        contentDescription = "Bookmark",
                        tint = if (post.isBookmarked) BlinkPurple else MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier
                            .size(22.dp)
                            .scale(bookmarkScale)
                    )
                }
            }
        }
    }
}

@Composable
fun HighlightedText(
    text: String,
    accentColor: Color,
    textColor: Color,
    modifier: Modifier = Modifier
) {
    val annotated = remember(text, accentColor, textColor) {
        buildAnnotatedString {
            val words = text.split(" ")
            words.forEachIndexed { index, word ->
                if (word.startsWith("#") || word.startsWith("@")) {
                    withStyle(
                        style = SpanStyle(
                            color = accentColor,
                            fontWeight = FontWeight.Bold
                        )
                    ) {
                        append(word)
                    }
                } else {
                    withStyle(style = SpanStyle(color = textColor)) {
                        append(word)
                    }
                }
                if (index < words.size - 1) append(" ")
            }
        }
    }

    Text(
        text = annotated,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        modifier = modifier
    )
}

fun formatNumber(number: Int): String {
    return when {
        number >= 1_000_000 -> String.format("%.1fM", number / 1_000_000.0).replace(".0M", "M")
        number >= 1_000 -> String.format("%.1fK", number / 1_000.0).replace(".0K", "K")
        else -> number.toString()
    }
}
