package com.example.ui.screens

import android.content.Intent
import android.net.Uri
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
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
    onBack: () -> Unit,
    onEditProfileClick: () -> Unit,
    onDirectMessage: (String) -> Unit,
    onEndorseSkill: (String) -> Unit,
    onLikePost: (String) -> Unit,
    onCommentPost: (String) -> Unit,
    onBookmarkPost: (String) -> Unit,
    onSharePost: (String) -> Unit,
    isDark: Boolean
) {
    var selectedProfileTab by remember { mutableIntStateOf(0) } // 0: Posts, 1: Skills, 2: About

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
            // 1. Cover Photo with Safe Insets & Navigation Actions
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(180.dp)
                ) {
                    // Cover Image
                    AsyncImage(
                        model = profile.coverPhotoUrl,
                        contentDescription = "Cover photo",
                        contentScale = ContentScale.Crop,
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(180.dp)
                    )

                    // Top navigation bar with scrim
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

            // 2. Avatar & Action Button Row (Clean & Non-overlapping)
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
                        // Avatar
                        Box(
                            modifier = Modifier
                                .size(92.dp)
                                .shadow(8.dp, CircleShape)
                        ) {
                            AsyncImage(
                                model = profile.avatarUrl,
                                contentDescription = profile.fullName,
                                contentScale = ContentScale.Crop,
                                modifier = Modifier
                                    .fillMaxSize()
                                    .clip(CircleShape)
                                    .border(3.5.dp, bgColor, CircleShape)
                            )

                            if (profile.verificationBadge != VerificationBadge.NONE) {
                                Box(
                                    modifier = Modifier
                                        .align(Alignment.BottomEnd)
                                        .offset(x = (-2).dp, y = (-2).dp)
                                ) {
                                    VerifiedMark(badge = profile.verificationBadge, size = 24.dp)
                                }
                            }
                        }

                        // Action Buttons on Right
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.padding(bottom = 6.dp)
                        ) {
                            if (isMe) {
                                Button(
                                    onClick = onEditProfileClick,
                                    colors = ButtonDefaults.buttonColors(containerColor = BlinkPink),
                                    shape = RoundedCornerShape(100.dp),
                                    contentPadding = PaddingValues(horizontal = 18.dp, vertical = 8.dp),
                                    modifier = Modifier
                                        .height(38.dp)
                                        .testTag("edit_profile_button")
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.Edit,
                                        contentDescription = null,
                                        tint = Color.White,
                                        modifier = Modifier.size(14.dp)
                                    )
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text(
                                        "Edit Profile",
                                        fontSize = 13.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = Color.White
                                    )
                                }
                            } else {
                                Button(
                                    onClick = { onDirectMessage(profile.username) },
                                    colors = ButtonDefaults.buttonColors(containerColor = BlinkPink),
                                    shape = RoundedCornerShape(100.dp),
                                    contentPadding = PaddingValues(horizontal = 18.dp, vertical = 8.dp),
                                    modifier = Modifier.height(38.dp)
                                ) {
                                    Icon(
                                        imageVector = Icons.AutoMirrored.Filled.Chat,
                                        contentDescription = null,
                                        tint = Color.White,
                                        modifier = Modifier.size(14.dp)
                                    )
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text(
                                        "Message",
                                        fontSize = 13.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = Color.White
                                    )
                                }
                            }
                        }
                    }

                    // 3. User Identity Details
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .offset(y = (-32).dp)
                    ) {
                        // Full Name + Faculty Tag
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Text(
                                text = profile.fullName,
                                fontSize = 21.sp,
                                fontWeight = FontWeight.Black,
                                color = textPrimary,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                            FacultyBadge(tag = profile.faculty)
                        }

                        Spacer(modifier = Modifier.height(2.dp))

                        // Username
                        Text(
                            text = "@${profile.username}",
                            fontSize = 13.5.sp,
                            fontWeight = FontWeight.Medium,
                            color = textSecondary
                        )

                        Spacer(modifier = Modifier.height(8.dp))

                        // Professional Headline
                        if (profile.professionalHeadline.isNotBlank()) {
                            Text(
                                text = profile.professionalHeadline,
                                fontSize = 14.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = BlinkPink
                            )
                        }

                        if (profile.currentJobTitle.isNotBlank()) {
                            Text(
                                text = profile.currentJobTitle,
                                fontSize = 13.sp,
                                color = textPrimary
                            )
                        }

                        // Bio
                        if (profile.bio.isNotBlank()) {
                            Spacer(modifier = Modifier.height(8.dp))
                            Text(
                                text = profile.bio,
                                fontSize = 13.5.sp,
                                lineHeight = 19.sp,
                                color = textPrimary
                            )
                        }

                        Spacer(modifier = Modifier.height(14.dp))

                        // Academic Credentials Card
                        Surface(
                            shape = RoundedCornerShape(16.dp),
                            color = cardBg,
                            border = androidx.compose.foundation.BorderStroke(1.dp, borderColor),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Row(
                                modifier = Modifier.padding(14.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(12.dp)
                            ) {
                                Box(
                                    modifier = Modifier
                                        .size(42.dp)
                                        .clip(RoundedCornerShape(12.dp))
                                        .background(BlinkPink.copy(alpha = 0.15f)),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.School,
                                        contentDescription = null,
                                        tint = BlinkPink,
                                        modifier = Modifier.size(22.dp)
                                    )
                                }

                                Column(modifier = Modifier.weight(1f)) {
                                    Text(
                                        text = profile.university,
                                        fontSize = 13.5.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = textPrimary,
                                        maxLines = 1,
                                        overflow = TextOverflow.Ellipsis
                                    )
                                    Text(
                                        text = "${profile.department} • ${profile.academicLevel} (${profile.graduationYear})",
                                        fontSize = 12.sp,
                                        color = textSecondary
                                    )
                                }
                            }
                        }

                        Spacer(modifier = Modifier.height(14.dp))

                        // Stats Row
                        Surface(
                            shape = RoundedCornerShape(16.dp),
                            color = cardBg,
                            border = androidx.compose.foundation.BorderStroke(1.dp, borderColor),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(vertical = 12.dp),
                                horizontalArrangement = Arrangement.SpaceEvenly,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                ProfileStatItem(count = profile.followerCount.toString(), label = "Followers", isDark = isDark)
                                Box(modifier = Modifier.width(1.dp).height(24.dp).background(borderColor))
                                ProfileStatItem(count = profile.followingCount.toString(), label = "Following", isDark = isDark)
                                Box(modifier = Modifier.width(1.dp).height(24.dp).background(borderColor))
                                ProfileStatItem(count = profile.profileViewsThisWeek.toString(), label = "Weekly Views", isDark = isDark)
                            }
                        }

                        Spacer(modifier = Modifier.height(16.dp))

                        // Profile Tabs Selector
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(100.dp))
                                .background(cardBg)
                                .border(1.dp, borderColor, RoundedCornerShape(100.dp))
                                .padding(4.dp),
                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            listOf("Posts", "Skills & Badges", "About & Links").forEachIndexed { index, label ->
                                val isSelected = selectedProfileTab == index
                                val tabBg by animateColorAsState(
                                    targetValue = if (isSelected) BlinkPink else Color.Transparent,
                                    animationSpec = tween(200),
                                    label = "tabBg"
                                )
                                val textColor by animateColorAsState(
                                    targetValue = if (isSelected) Color.White else textSecondary,
                                    animationSpec = tween(200),
                                    label = "tabText"
                                )

                                Box(
                                    modifier = Modifier
                                        .weight(1f)
                                        .clip(RoundedCornerShape(100.dp))
                                        .background(tabBg)
                                        .clickable { selectedProfileTab = index }
                                        .padding(vertical = 8.dp),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        text = label,
                                        fontSize = 12.sp,
                                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                                        color = textColor,
                                        maxLines = 1
                                    )
                                }
                            }
                        }
                    }
                }
            }

            // 4. Tab Content
            when (selectedProfileTab) {
                0 -> {
                    val authoredPosts = userPosts.filter { it.author == profile.username }
                    if (authoredPosts.isEmpty()) {
                        item {
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(vertical = 40.dp, horizontal = 20.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Icon(
                                        imageVector = Icons.Outlined.Article,
                                        contentDescription = null,
                                        tint = textSecondary,
                                        modifier = Modifier.size(44.dp)
                                    )
                                    Spacer(modifier = Modifier.height(10.dp))
                                    Text(
                                        text = "No posts shared yet.",
                                        fontSize = 14.sp,
                                        fontWeight = FontWeight.Medium,
                                        color = textSecondary
                                    )
                                }
                            }
                        }
                    } else {
                        items(authoredPosts, key = { it.id }) { post ->
                            PostCard(
                                post = post,
                                isDark = isDark,
                                onLike = { onLikePost(post.id) },
                                onComment = { onCommentPost(post.id) },
                                onBookmark = { onBookmarkPost(post.id) },
                                onShare = { onSharePost(post.id) },
                                onProfileClick = {}
                            )
                        }
                    }
                }

                1 -> {
                    item {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 18.dp),
                            verticalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            Text(
                                text = "Tap any skill to endorse +1 ✨",
                                fontSize = 12.5.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = textSecondary
                            )

                            profile.skillEndorsements.forEach { endorsement ->
                                Surface(
                                    shape = RoundedCornerShape(14.dp),
                                    color = cardBg,
                                    border = androidx.compose.foundation.BorderStroke(1.dp, borderColor),
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
                                fontSize = 14.5.sp,
                                fontWeight = FontWeight.Bold,
                                color = textPrimary
                            )

                            profile.badges.forEach { badge ->
                                Surface(
                                    shape = RoundedCornerShape(14.dp),
                                    color = cardBg,
                                    border = androidx.compose.foundation.BorderStroke(1.dp, borderColor),
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
                }

                2 -> {
                    item {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 18.dp),
                            verticalArrangement = Arrangement.spacedBy(14.dp)
                        ) {
                            Surface(
                                shape = RoundedCornerShape(16.dp),
                                color = cardBg,
                                border = androidx.compose.foundation.BorderStroke(1.dp, borderColor),
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
                                border = androidx.compose.foundation.BorderStroke(1.dp, borderColor),
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
