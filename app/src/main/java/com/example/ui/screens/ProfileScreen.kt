package com.example.ui.screens

import android.content.Intent
import android.net.Uri
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.Chat
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.example.data.models.FeedPost
import com.example.data.models.UserProfile
import com.example.data.models.VerificationBadge
import com.example.ui.components.FacultyBadge
import com.example.ui.components.PostCard
import com.example.ui.components.VerifiedMark
import com.example.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(
    profile: UserProfile,
    isMe: Boolean,
    userPosts: List<FeedPost>,
    likedPosts: List<FeedPost>,
    savedPosts: List<FeedPost>,
    onBack: () -> Unit,
    onEditProfileClick: () -> Unit,
    onDirectMessage: (String) -> Unit,
    onEndorseSkill: (String) -> Unit,
    onLikePost: (String) -> Unit,
    onCommentPost: (String) -> Unit,
    onBookmarkPost: (String) -> Unit,
    onSharePost: (String) -> Unit,
    onOptionsClick: (FeedPost) -> Unit,
    onProfileClick: (String) -> Unit,
    onOpenGetVerified: () -> Unit = {},
    isDark: Boolean
) {
    var selectedTab by remember { mutableIntStateOf(0) }
    var isFollowing by remember { mutableStateOf(false) }

    val tabs = remember(isMe) {
        if (isMe) {
            listOf("Posts", "Liked", "Saved", "Skills & Badges", "About")
        } else {
            listOf("Posts", "Liked", "Skills & Badges", "About")
        }
    }

    val bgColor = if (isDark) DarkBackground else LightBackground
    val cardBg = if (isDark) DarkSurface else LightSurface
    val textPrimary = if (isDark) Color.White else LightTextPrimary
    val textSecondary = if (isDark) DarkTextSecondary else LightTextSecondary
    val borderColor = if (isDark) DarkBorder else LightBorder

    Surface(
        modifier = Modifier
            .fillMaxSize()
            .testTag("profile_screen"),
        color = bgColor
    ) {
        LazyColumn(
            contentPadding = PaddingValues(bottom = 120.dp),
            modifier = Modifier.fillMaxSize()
        ) {
            // 1. Cover Photo & Navigation Header
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(180.dp)
                ) {
                    AsyncImage(
                        model = profile.coverPhotoUrl,
                        contentDescription = "Cover photo",
                        contentScale = ContentScale.Crop,
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(180.dp)
                    )

                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(75.dp)
                            .background(
                                Brush.verticalGradient(
                                    colors = listOf(Color(0x99000000), Color.Transparent)
                                )
                            )
                    )

                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .statusBarsPadding()
                            .padding(horizontal = 16.dp, vertical = 8.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        IconButton(
                            onClick = onBack,
                            modifier = Modifier
                                .size(40.dp)
                                .background(Color(0x66000000), CircleShape)
                                .testTag("profile_back_btn")
                        ) {
                            Icon(
                                imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                                contentDescription = "Back",
                                tint = Color.White,
                                modifier = Modifier.size(20.dp)
                            )
                        }

                        if (isMe) {
                            IconButton(
                                onClick = onEditProfileClick,
                                modifier = Modifier
                                    .size(40.dp)
                                    .background(Color(0x66000000), CircleShape)
                                    .testTag("profile_edit_icon_btn")
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Edit,
                                    contentDescription = "Edit Profile",
                                    tint = Color.White,
                                    modifier = Modifier.size(20.dp)
                                )
                            }
                        }
                    }
                }
            }

            // 2. Avatar & Action Buttons
            item {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 18.dp)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .offset(y = (-44).dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.Bottom
                    ) {
                        Box {
                            AsyncImage(
                                model = profile.avatarUrl,
                                contentDescription = profile.fullName,
                                contentScale = ContentScale.Crop,
                                modifier = Modifier
                                    .size(88.dp)
                                    .clip(CircleShape)
                                    .border(3.dp, bgColor, CircleShape)
                                    .shadow(6.dp, CircleShape)
                            )
                            if (profile.onlineNow) {
                                Box(
                                    modifier = Modifier
                                        .size(16.dp)
                                        .clip(CircleShape)
                                        .background(Color(0xFF22C55E))
                                        .border(2.dp, bgColor, CircleShape)
                                        .align(Alignment.BottomEnd)
                                )
                            }
                        }

                        Row(
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            if (isMe) {
                                Button(
                                    onClick = onEditProfileClick,
                                    colors = ButtonDefaults.buttonColors(
                                        containerColor = MaterialTheme.colorScheme.surfaceVariant
                                    ),
                                    shape = RoundedCornerShape(100.dp),
                                    contentPadding = PaddingValues(horizontal = 14.dp, vertical = 8.dp),
                                    modifier = Modifier.testTag("profile_edit_profile_btn")
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.Edit,
                                        contentDescription = null,
                                        tint = textPrimary,
                                        modifier = Modifier.size(15.dp)
                                    )
                                    Spacer(modifier = Modifier.width(5.dp))
                                    Text(
                                        "Edit",
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 12.5.sp,
                                        color = textPrimary
                                    )
                                }

                                // Get Verified Button
                                Button(
                                    onClick = onOpenGetVerified,
                                    colors = ButtonDefaults.buttonColors(
                                        containerColor = when (profile.verificationBadge) {
                                            VerificationBadge.GOLD -> BlinkGold
                                            VerificationBadge.BLUE -> BlinkBlue
                                            VerificationBadge.NONE -> BlinkPink
                                        }
                                    ),
                                    shape = RoundedCornerShape(100.dp),
                                    contentPadding = PaddingValues(horizontal = 14.dp, vertical = 8.dp),
                                    modifier = Modifier.testTag("profile_get_verified_btn")
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.Verified,
                                        contentDescription = null,
                                        tint = if (profile.verificationBadge == VerificationBadge.GOLD) Color.Black else Color.White,
                                        modifier = Modifier.size(16.dp)
                                    )
                                    Spacer(modifier = Modifier.width(5.dp))
                                    Text(
                                        text = when (profile.verificationBadge) {
                                            VerificationBadge.GOLD -> "Gold VIP"
                                            VerificationBadge.BLUE -> "Upgrade Gold"
                                            VerificationBadge.NONE -> "Get Verified"
                                        },
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 12.5.sp,
                                        color = if (profile.verificationBadge == VerificationBadge.GOLD) Color.Black else Color.White
                                    )
                                }
                            } else {
                                // Direct Message Button
                                Button(
                                    onClick = { onDirectMessage(profile.username) },
                                    colors = ButtonDefaults.buttonColors(
                                        containerColor = BlinkPurple
                                    ),
                                    shape = RoundedCornerShape(100.dp),
                                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                                    modifier = Modifier.testTag("profile_message_btn")
                                ) {
                                    Icon(
                                        imageVector = Icons.AutoMirrored.Filled.Chat,
                                        contentDescription = "Message",
                                        tint = Color.White,
                                        modifier = Modifier.size(16.dp)
                                    )
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text(
                                        "Message",
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 13.sp,
                                        color = Color.White
                                    )
                                }

                                // Follow / Following Button
                                Button(
                                    onClick = { isFollowing = !isFollowing },
                                    colors = ButtonDefaults.buttonColors(
                                        containerColor = if (isFollowing) MaterialTheme.colorScheme.surfaceVariant else BlinkPink
                                    ),
                                    shape = RoundedCornerShape(100.dp),
                                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                                    modifier = Modifier.testTag("profile_follow_btn")
                                ) {
                                    Text(
                                        if (isFollowing) "Following" else "Follow",
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 13.sp,
                                        color = if (isFollowing) textPrimary else Color.White
                                    )
                                }
                            }
                        }
                    }

                    // Profile Details & Bio
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .offset(y = (-28).dp)
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Text(
                                text = profile.fullName,
                                fontSize = 20.sp,
                                fontWeight = FontWeight.Black,
                                color = textPrimary
                            )
                            if (profile.verificationBadge != VerificationBadge.NONE) {
                                VerifiedMark(badge = profile.verificationBadge, size = 18.dp)
                            }
                        }

                        Text(
                            text = "@${profile.username}",
                            fontSize = 13.5.sp,
                            color = BlinkPink,
                            fontWeight = FontWeight.SemiBold
                        )

                        Spacer(modifier = Modifier.height(6.dp))

                        Text(
                            text = profile.professionalHeadline,
                            fontSize = 13.5.sp,
                            fontWeight = FontWeight.Medium,
                            color = textPrimary
                        )

                        Spacer(modifier = Modifier.height(4.dp))

                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            FacultyBadge(tag = profile.faculty)
                            Text(
                                text = "${profile.university} • ${profile.academicLevel}",
                                fontSize = 12.sp,
                                color = textSecondary
                            )
                        }

                        if (profile.bio.isNotBlank()) {
                            Spacer(modifier = Modifier.height(10.dp))
                            Text(
                                text = profile.bio,
                                fontSize = 13.5.sp,
                                lineHeight = 19.sp,
                                color = textPrimary
                            )
                        }

                        Spacer(modifier = Modifier.height(16.dp))

                        // Followers / Following / Points Stats Row
                        Surface(
                            shape = RoundedCornerShape(16.dp),
                            color = cardBg,
                            border = BorderStroke(1.dp, borderColor),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(vertical = 12.dp),
                                horizontalArrangement = Arrangement.SpaceEvenly,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                ProfileStatItem(count = "${userPosts.size}", label = "Posts", isDark = isDark)
                                Box(modifier = Modifier.height(28.dp).width(1.dp).background(borderColor))
                                ProfileStatItem(count = "${profile.followerCount + if (isFollowing) 1 else 0}", label = "Followers", isDark = isDark)
                                Box(modifier = Modifier.height(28.dp).width(1.dp).background(borderColor))
                                ProfileStatItem(count = "${profile.followingCount}", label = "Following", isDark = isDark)
                            }
                        }
                    }
                }
            }

            // 3. Tab Bar
            item {
                LazyRow(
                    contentPadding = PaddingValues(horizontal = 16.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .offset(y = (-14).dp)
                ) {
                    items(tabs.indices.toList()) { index ->
                        val isSelected = selectedTab == index
                        Surface(
                            shape = RoundedCornerShape(100.dp),
                            color = if (isSelected) BlinkPink else cardBg,
                            border = BorderStroke(
                                1.dp,
                                if (isSelected) BlinkPink else borderColor
                            ),
                            modifier = Modifier
                                .clickable { selectedTab = index }
                                .testTag("profile_tab_$index")
                        ) {
                            Text(
                                text = tabs[index],
                                fontSize = 13.sp,
                                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                                color = if (isSelected) Color.White else textPrimary,
                                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                            )
                        }
                    }
                }
            }

            // 4. Tab Contents
            when (selectedTab) {
                // TAB: POSTS
                0 -> {
                    if (userPosts.isEmpty()) {
                        item {
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(32.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Text(
                                        text = "No posts yet 📝",
                                        fontSize = 16.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = textPrimary
                                    )
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(
                                        text = "Posts published by @${profile.username} will show up here.",
                                        fontSize = 12.5.sp,
                                        color = textSecondary,
                                        textAlign = TextAlign.Center
                                    )
                                }
                            }
                        }
                    } else {
                        items(userPosts, key = { it.id }) { post ->
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

                // TAB: LIKED
                1 -> {
                    if (likedPosts.isEmpty()) {
                        item {
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(32.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Text(
                                        text = "No liked posts yet ❤️",
                                        fontSize = 16.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = textPrimary
                                    )
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(
                                        text = "Posts that have been liked will appear in this feed.",
                                        fontSize = 12.5.sp,
                                        color = textSecondary,
                                        textAlign = TextAlign.Center
                                    )
                                }
                            }
                        }
                    } else {
                        items(likedPosts, key = { it.id }) { post ->
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

                // TAB: SAVED (if isMe) or SKILLS & BADGES (if !isMe)
                2 -> {
                    if (isMe) {
                        // Personal Saved Posts
                        if (savedPosts.isEmpty()) {
                            item {
                                Box(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(32.dp),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                        Text(
                                            text = "No saved posts 🔖",
                                            fontSize = 16.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = textPrimary
                                        )
                                        Spacer(modifier = Modifier.height(4.dp))
                                        Text(
                                            text = "Bookmark useful exam tips, tech projects, and campus deals to view here.",
                                            fontSize = 12.5.sp,
                                            color = textSecondary,
                                            textAlign = TextAlign.Center
                                        )
                                    }
                                }
                            }
                        } else {
                            items(savedPosts, key = { it.id }) { post ->
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
                    } else {
                        // Skills & Badges for other users
                        item {
                            SkillsAndBadgesSection(
                                profile = profile,
                                isMe = isMe,
                                cardBg = cardBg,
                                borderColor = borderColor,
                                textPrimary = textPrimary,
                                textSecondary = textSecondary,
                                onEndorseSkill = onEndorseSkill,
                                onOpenGetVerified = onOpenGetVerified
                            )
                        }
                    }
                }

                // TAB 3: SKILLS & BADGES (for isMe) or ABOUT (for !isMe)
                3 -> {
                    if (isMe) {
                        item {
                            SkillsAndBadgesSection(
                                profile = profile,
                                isMe = isMe,
                                cardBg = cardBg,
                                borderColor = borderColor,
                                textPrimary = textPrimary,
                                textSecondary = textSecondary,
                                onEndorseSkill = onEndorseSkill,
                                onOpenGetVerified = onOpenGetVerified
                            )
                        }
                    } else {
                        item {
                            AboutSection(
                                profile = profile,
                                cardBg = cardBg,
                                borderColor = borderColor,
                                textPrimary = textPrimary
                            )
                        }
                    }
                }

                // TAB 4: ABOUT (for isMe)
                4 -> {
                    item {
                        AboutSection(
                            profile = profile,
                            cardBg = cardBg,
                            borderColor = borderColor,
                            textPrimary = textPrimary
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun SkillsAndBadgesSection(
    profile: UserProfile,
    isMe: Boolean,
    cardBg: Color,
    borderColor: Color,
    textPrimary: Color,
    textSecondary: Color,
    onEndorseSkill: (String) -> Unit,
    onOpenGetVerified: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 18.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        // Verification & Trust Banner
        Surface(
            shape = RoundedCornerShape(16.dp),
            color = cardBg,
            border = BorderStroke(
                1.5.dp,
                when (profile.verificationBadge) {
                    VerificationBadge.GOLD -> BlinkGold
                    VerificationBadge.BLUE -> BlinkBlue
                    VerificationBadge.NONE -> borderColor
                }
            ),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        VerifiedMark(
                            badge = if (profile.verificationBadge == VerificationBadge.NONE) VerificationBadge.BLUE else profile.verificationBadge,
                            size = 28.dp
                        )
                        Column {
                            Text(
                                text = when (profile.verificationBadge) {
                                    VerificationBadge.GOLD -> "Gold VIP Verified"
                                    VerificationBadge.BLUE -> "Blue Verified Student"
                                    VerificationBadge.NONE -> "Get Campus Verified"
                                },
                                fontSize = 15.sp,
                                fontWeight = FontWeight.Bold,
                                color = textPrimary
                            )
                            Text(
                                text = when (profile.verificationBadge) {
                                    VerificationBadge.GOLD -> "5x Post Reach • Top Aluta Merchant Pro"
                                    VerificationBadge.BLUE -> "Verified Member • Aluta Market Posting Active"
                                    VerificationBadge.NONE -> "Blue (₦800) • Gold (1k Followers + ₦2,000)"
                                },
                                fontSize = 11.5.sp,
                                color = textSecondary
                            )
                        }
                    }

                    if (isMe) {
                        Button(
                            onClick = onOpenGetVerified,
                            colors = ButtonDefaults.buttonColors(
                                containerColor = when (profile.verificationBadge) {
                                    VerificationBadge.GOLD -> BlinkGold
                                    VerificationBadge.BLUE -> BlinkBlue
                                    VerificationBadge.NONE -> BlinkPink
                                }
                            ),
                            shape = RoundedCornerShape(100.dp),
                            contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp)
                        ) {
                            Text(
                                text = when (profile.verificationBadge) {
                                    VerificationBadge.GOLD -> "VIP Status"
                                    VerificationBadge.BLUE -> "Upgrade Gold"
                                    VerificationBadge.NONE -> "Get Verified"
                                },
                                fontSize = 11.5.sp,
                                fontWeight = FontWeight.Bold,
                                color = if (profile.verificationBadge == VerificationBadge.GOLD) Color.Black else Color.White
                            )
                        }
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(4.dp))

        Text(
            text = "Skills & Campus Endorsements",
            fontSize = 15.sp,
            fontWeight = FontWeight.Bold,
            color = textPrimary
        )

        profile.skillEndorsements.forEach { endorsement ->
            Surface(
                shape = RoundedCornerShape(14.dp),
                color = cardBg,
                border = BorderStroke(1.dp, borderColor),
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { onEndorseSkill(endorsement.skill) }
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(14.dp)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Stars,
                            contentDescription = null,
                            tint = if (endorsement.endorsedByMe) BlinkGold else BlinkPink,
                            modifier = Modifier.size(22.dp)
                        )
                        Text(
                            text = endorsement.skill,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Bold,
                            color = textPrimary
                        )
                    }

                    Surface(
                        shape = RoundedCornerShape(100.dp),
                        color = if (endorsement.endorsedByMe) BlinkGold else BlinkPink.copy(alpha = 0.15f)
                    ) {
                        Text(
                            text = "${endorsement.endorsements} endorsements",
                            fontSize = 11.5.sp,
                            fontWeight = FontWeight.Bold,
                            color = if (endorsement.endorsedByMe) Color.Black else BlinkPink,
                            modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                        )
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = "Campus Achievements",
            fontSize = 15.sp,
            fontWeight = FontWeight.Bold,
            color = textPrimary
        )

        profile.badges.forEach { badge ->
            Surface(
                shape = RoundedCornerShape(14.dp),
                color = cardBg,
                border = BorderStroke(1.dp, borderColor),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    modifier = Modifier.padding(14.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .size(40.dp)
                            .clip(CircleShape)
                            .background(BlinkGold.copy(alpha = 0.18f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.WorkspacePremium,
                            contentDescription = null,
                            tint = BlinkGold,
                            modifier = Modifier.size(24.dp)
                        )
                    }
                    Column {
                        Text(
                            text = badge.title,
                            fontSize = 13.5.sp,
                            fontWeight = FontWeight.Bold,
                            color = textPrimary
                        )
                        Text(
                            text = badge.description,
                            fontSize = 11.5.sp,
                            color = textSecondary
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun AboutSection(
    profile: UserProfile,
    cardBg: Color,
    borderColor: Color,
    textPrimary: Color
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 18.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        Surface(
            shape = RoundedCornerShape(16.dp),
            color = cardBg,
            border = BorderStroke(1.dp, borderColor),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(
                modifier = Modifier.padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Text(
                    "Contact & Campus Location",
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp,
                    color = textPrimary
                )

                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    Icon(Icons.Default.Email, contentDescription = null, tint = BlinkPink, modifier = Modifier.size(18.dp))
                    Text(profile.email.value, fontSize = 13.sp, color = textPrimary)
                }

                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    Icon(Icons.Default.Phone, contentDescription = null, tint = BlinkPink, modifier = Modifier.size(18.dp))
                    Text(profile.phone.value, fontSize = 13.sp, color = textPrimary)
                }

                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    Icon(Icons.Default.LocationOn, contentDescription = null, tint = BlinkPink, modifier = Modifier.size(18.dp))
                    Text(profile.currentCityState, fontSize = 13.sp, color = textPrimary)
                }
            }
        }

        Surface(
            shape = RoundedCornerShape(16.dp),
            color = cardBg,
            border = BorderStroke(1.dp, borderColor),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(
                modifier = Modifier.padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Text(
                    "Socials & Student Portfolio",
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp,
                    color = textPrimary
                )

                if (profile.links.website.isNotBlank()) {
                    SocialLinkRow(
                        icon = Icons.Default.Language,
                        title = "Website",
                        url = profile.links.website,
                        textColor = textPrimary
                    )
                }
                if (profile.links.linkedin.isNotBlank()) {
                    SocialLinkRow(
                        icon = Icons.Default.Link,
                        title = "LinkedIn",
                        url = profile.links.linkedin,
                        textColor = textPrimary
                    )
                }
                if (profile.links.twitter.isNotBlank()) {
                    SocialLinkRow(
                        icon = Icons.Default.Share,
                        title = "X / Twitter",
                        url = profile.links.twitter,
                        textColor = textPrimary
                    )
                }
            }
        }
    }
}

@Composable
private fun ProfileStatItem(count: String, label: String, isDark: Boolean) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = count,
            fontSize = 18.sp,
            fontWeight = FontWeight.Black,
            color = if (isDark) Color.White else LightTextPrimary
        )
        Text(
            text = label,
            fontSize = 11.5.sp,
            color = if (isDark) DarkTextSecondary else LightTextSecondary
        )
    }
}

@Composable
private fun SocialLinkRow(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    title: String,
    url: String,
    textColor: Color
) {
    val context = LocalContext.current
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween,
        modifier = Modifier
            .fillMaxWidth()
            .clickable {
                try {
                    val fullUrl = if (!url.startsWith("http://") && !url.startsWith("https://")) "https://$url" else url
                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(fullUrl))
                    context.startActivity(intent)
                } catch (e: Exception) {
                    // Ignore
                }
            }
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Icon(icon, contentDescription = null, tint = BlinkPink, modifier = Modifier.size(18.dp))
            Text(title, fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = textColor)
        }
        Text(url, fontSize = 11.5.sp, color = BlinkPurple, maxLines = 1, overflow = TextOverflow.Ellipsis)
    }
}
