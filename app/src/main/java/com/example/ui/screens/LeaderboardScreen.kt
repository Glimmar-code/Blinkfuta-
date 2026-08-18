package com.example.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.example.data.models.LeaderboardUser
import com.example.ui.components.FacultyBadge
import com.example.ui.theme.*

@Composable
fun LeaderboardScreen(
    users: List<LeaderboardUser>,
    onProfileClick: (String) -> Unit,
    isDark: Boolean
) {
    val top1 = users.getOrNull(0)
    val top2 = users.getOrNull(1)
    val top3 = users.getOrNull(2)
    val remainingUsers = if (users.size > 3) users.subList(3, users.size) else emptyList()

    LazyColumn(
        contentPadding = PaddingValues(bottom = 120.dp),
        modifier = Modifier
            .fillMaxSize()
            .testTag("leaderboard_screen")
    ) {
        // Header
        item {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(start = 20.dp, end = 20.dp, top = 48.dp, bottom = 16.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.EmojiEvents,
                        contentDescription = "Trophy",
                        tint = BlinkGold,
                        modifier = Modifier.size(28.dp)
                    )
                    Text(
                        text = "Campus Leaderboard",
                        fontSize = 22.sp,
                        fontWeight = FontWeight.Black,
                        color = MaterialTheme.colorScheme.onBackground
                    )
                }

                Text(
                    text = "Weekly top contributors, student builders & creator rankings",
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(top = 4.dp)
                )
            }
        }

        // Top 3 Podium
        item {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 12.dp),
                horizontalArrangement = Arrangement.SpaceEvenly,
                verticalAlignment = Alignment.Bottom
            ) {
                // 2nd Place (Silver)
                if (top2 != null) {
                    PodiumUserCard(
                        user = top2,
                        rank = 2,
                        accentColor = Color(0xFFC0C0C0),
                        podiumHeight = 110.dp,
                        onProfileClick = onProfileClick,
                        isDark = isDark
                    )
                }

                // 1st Place (Gold - Taller in center)
                if (top1 != null) {
                    PodiumUserCard(
                        user = top1,
                        rank = 1,
                        accentColor = BlinkGold,
                        podiumHeight = 140.dp,
                        onProfileClick = onProfileClick,
                        isDark = isDark
                    )
                }

                // 3rd Place (Bronze)
                if (top3 != null) {
                    PodiumUserCard(
                        user = top3,
                        rank = 3,
                        accentColor = Color(0xFFCD7F32),
                        podiumHeight = 90.dp,
                        onProfileClick = onProfileClick,
                        isDark = isDark
                    )
                }
            }
        }

        // Section Title
        item {
            Text(
                text = "Rankings",
                fontSize = 15.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onSurface,
                modifier = Modifier.padding(start = 20.dp, top = 20.dp, bottom = 8.dp)
            )
        }

        // List of Rank 4+
        itemsIndexed(remainingUsers) { index, user ->
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 4.dp)
                    .clickable { onProfileClick(user.username) }
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(12.dp)
                ) {
                    Text(
                        text = "#${user.rank}",
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Black,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.width(36.dp)
                    )

                    AsyncImage(
                        model = user.avatar,
                        contentDescription = user.fullName,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier
                            .size(44.dp)
                            .clip(CircleShape)
                    )

                    Spacer(modifier = Modifier.width(12.dp))

                    Column(modifier = Modifier.weight(1f)) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            Text(
                                text = user.fullName,
                                fontSize = 14.sp,
                                fontWeight = FontWeight.Bold,
                                color = MaterialTheme.colorScheme.onSurface
                            )
                            FacultyBadge(tag = user.faculty)
                        }

                        Text(
                            text = "@${user.username} • ${user.university}",
                            fontSize = 11.5.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }

                    Column(horizontalAlignment = Alignment.End) {
                        Text(
                            text = "${user.points}",
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Black,
                            color = BlinkPink
                        )
                        Text(
                            text = "points",
                            fontSize = 10.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun PodiumUserCard(
    user: LeaderboardUser,
    rank: Int,
    accentColor: Color,
    podiumHeight: androidx.compose.ui.unit.Dp,
    onProfileClick: (String) -> Unit,
    isDark: Boolean
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier
            .width(100.dp)
            .clickable { onProfileClick(user.username) }
    ) {
        // Crown icon for 1st place
        if (rank == 1) {
            Icon(
                imageVector = Icons.Default.Stars,
                contentDescription = "Champion",
                tint = BlinkGold,
                modifier = Modifier.size(24.dp)
            )
            Spacer(modifier = Modifier.height(2.dp))
        }

        // Avatar with colored border
        Box(
            contentAlignment = Alignment.BottomCenter,
            modifier = Modifier.size(if (rank == 1) 68.dp else 56.dp)
        ) {
            AsyncImage(
                model = user.avatar,
                contentDescription = user.fullName,
                contentScale = ContentScale.Crop,
                modifier = Modifier
                    .fillMaxSize()
                    .clip(CircleShape)
                    .border(2.5.dp, accentColor, CircleShape)
            )

            Surface(
                shape = CircleShape,
                color = accentColor,
                modifier = Modifier
                    .offset(y = 6.dp)
                    .size(20.dp)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Text(
                        text = "$rank",
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Black,
                        color = Color.Black
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(10.dp))

        Text(
            text = user.fullName.split(" ").firstOrNull() ?: user.username,
            fontSize = 12.5.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onSurface,
            maxLines = 1
        )

        Text(
            text = "${user.points} pts",
            fontSize = 11.sp,
            fontWeight = FontWeight.SemiBold,
            color = BlinkPink
        )

        Spacer(modifier = Modifier.height(6.dp))

        // Pedestal base
        Surface(
            shape = RoundedCornerShape(topStart = 14.dp, topEnd = 14.dp),
            color = if (isDark) MaterialTheme.colorScheme.surface else Color.White,
            modifier = Modifier
                .fillMaxWidth()
                .height(podiumHeight)
                .border(
                    1.dp,
                    accentColor.copy(alpha = 0.4f),
                    RoundedCornerShape(topStart = 14.dp, topEnd = 14.dp)
                )
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center,
                modifier = Modifier.padding(6.dp)
            ) {
                Text(
                    text = "${user.streakDays}d 🔥",
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    color = BlinkGold
                )
                Text(
                    text = "streak",
                    fontSize = 9.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}
