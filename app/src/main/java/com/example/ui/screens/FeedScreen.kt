package com.example.ui.screens

import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.example.data.models.FeedPost
import com.example.data.models.Story
import com.example.ui.components.BlinkMark
import com.example.ui.components.PostCard
import com.example.ui.components.StoryBar
import com.example.ui.theme.BlinkPink

@Composable
fun FeedScreen(
    posts: List<FeedPost>,
    reels: List<FeedPost>,
    stories: List<Story>,
    userAvatar: String,
    currentSubTab: Int, // 0: Posts, 1: Reels
    onSubTabChanged: (Int) -> Unit,
    isDark: Boolean,
    onLikePost: (String) -> Unit,
    onCommentPost: (String) -> Unit,
    onBookmarkPost: (String) -> Unit,
    onSharePost: (String) -> Unit,
    onOptionsClick: (FeedPost) -> Unit,
    onProfileClick: (String) -> Unit,
    onAddStoryClick: () -> Unit,
    onStoryClick: (Story) -> Unit,
    onOpenCreatePost: () -> Unit,
    onOpenActivity: () -> Unit,
    onOpenMenu: () -> Unit,
    onToggleTheme: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .testTag("feed_screen")
    ) {
        if (currentSubTab == 1) {
            // Reels View
            VideoReelsScreen(
                reels = reels,
                isDark = isDark,
                onLike = onLikePost,
                onComment = onCommentPost,
                onBookmark = onBookmarkPost,
                onShare = onSharePost,
                onProfileClick = onProfileClick,
                onBackToPosts = { onSubTabChanged(0) }
            )
        } else {
            // Posts View
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(bottom = 110.dp)
            ) {
                // Top Header Bar
                item {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(start = 16.dp, end = 16.dp, top = 48.dp, bottom = 12.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        // 3-Dot menu button on top left
                        IconButton(
                            onClick = onOpenMenu,
                            modifier = Modifier.testTag("menu_3dots_button")
                        ) {
                            Icon(
                                imageVector = Icons.Default.MoreHoriz,
                                contentDescription = "App Menu",
                                tint = MaterialTheme.colorScheme.onSurface,
                                modifier = Modifier.size(28.dp)
                            )
                        }

                        // Logo in center
                        BlinkMark(size = 34.dp, showText = true)

                        // Top right icons: Notification and Profile
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            // Activity / Bell Icon (opens half sheet)
                            IconButton(
                                onClick = onOpenActivity,
                                modifier = Modifier.testTag("activity_button")
                            ) {
                                BadgedBox(
                                    badge = {
                                        Badge(
                                            containerColor = BlinkPink,
                                            modifier = Modifier.size(8.dp)
                                        )
                                    }
                                ) {
                                    Icon(
                                        imageVector = Icons.Outlined.Notifications,
                                        contentDescription = "Notifications",
                                        tint = MaterialTheme.colorScheme.onSurface,
                                        modifier = Modifier.size(24.dp)
                                    )
                                }
                            }

                            // Profile avatar icon on the top right
                            Box(
                                modifier = Modifier
                                    .size(36.dp)
                                    .clip(CircleShape)
                                    .clickable { onProfileClick("you") }
                                    .testTag("top_profile_button")
                            ) {
                                AsyncImage(
                                    model = userAvatar,
                                    contentDescription = "My Profile",
                                    contentScale = androidx.compose.ui.layout.ContentScale.Crop,
                                    modifier = Modifier.fillMaxSize()
                                )
                                Box(
                                    modifier = Modifier
                                        .size(10.dp)
                                        .background(Color(0xFF22C55E), CircleShape)
                                        .align(Alignment.BottomEnd)
                                )
                            }
                        }
                    }
                }

                // Story Bar
                item {
                    StoryBar(
                        stories = stories,
                        userAvatar = userAvatar,
                        onAddStory = onAddStoryClick,
                        onStoryClick = onStoryClick
                    )
                }

                // Posts vs Reels Segmented Pills
                item {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 10.dp),
                        horizontalArrangement = Arrangement.Center
                    ) {
                        Surface(
                            shape = RoundedCornerShape(100.dp),
                            color = if (isDark) MaterialTheme.colorScheme.surfaceVariant else Color(0xFFE9ECEF),
                            modifier = Modifier.padding(2.dp)
                        ) {
                            Row(
                                modifier = Modifier.padding(3.dp),
                                horizontalArrangement = Arrangement.spacedBy(4.dp)
                            ) {
                                SegmentedTabPill(
                                    title = "Campus Feed",
                                    isSelected = currentSubTab == 0,
                                    onClick = { onSubTabChanged(0) }
                                )
                                SegmentedTabPill(
                                    title = "Reels ✦",
                                    isSelected = currentSubTab == 1,
                                    onClick = { onSubTabChanged(1) }
                                )
                            }
                        }
                    }
                }

                // Feed Posts List
                items(posts, key = { it.id }) { post ->
                    PostCard(
                        post = post,
                        isDark = isDark,
                        onLike = { onLikePost(post.id) },
                        onComment = { onCommentPost(post.id) },
                        onBookmark = { onBookmarkPost(post.id) },
                        onShare = { onSharePost(post.id) },
                        onOptionsClick = { onOptionsClick(post) },
                        onProfileClick = onProfileClick
                    )
                }
            }
        }

        // Floating Action Button for Adding New Post (on Posts tab)
        if (currentSubTab == 0) {
            FloatingActionButton(
                onClick = onOpenCreatePost,
                containerColor = BlinkPink,
                contentColor = Color.White,
                shape = CircleShape,
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(end = 20.dp, bottom = 85.dp)
                    .testTag("create_post_fab")
            ) {
                Icon(Icons.Default.Add, contentDescription = "Create Post", modifier = Modifier.size(26.dp))
            }
        }
    }
}

@Composable
private fun SegmentedTabPill(
    title: String,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Surface(
        shape = RoundedCornerShape(100.dp),
        color = if (isSelected) BlinkPink else Color.Transparent,
        modifier = Modifier.clickable(
            interactionSource = remember { MutableInteractionSource() },
            indication = null
        ) { onClick() }
    ) {
        Text(
            text = title,
            fontSize = 13.sp,
            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
            color = if (isSelected) Color.White else MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(horizontal = 18.dp, vertical = 8.dp)
        )
    }
}
