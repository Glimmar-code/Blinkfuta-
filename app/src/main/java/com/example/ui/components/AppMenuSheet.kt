package com.example.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForwardIos
import androidx.compose.material.icons.automirrored.filled.Logout
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.example.data.models.UserProfile
import com.example.data.models.VerificationBadge
import com.example.ui.theme.BlinkPink
import com.example.ui.theme.BlinkPurple

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AppMenuSheet(
    profile: UserProfile,
    isDark: Boolean,
    onDismiss: () -> Unit,
    onViewProfile: () -> Unit,
    onEditProfile: () -> Unit,
    onOpenMarket: () -> Unit,
    onOpenPostItem: () -> Unit,
    onOpenBecomeSeller: () -> Unit,
    onOpenLeaderboard: () -> Unit,
    onOpenActivity: () -> Unit,
    onToggleTheme: () -> Unit,
    onLogout: () -> Unit,
    onShowToast: (String) -> Unit,
    onSimulateNotification: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        containerColor = if (isDark) MaterialTheme.colorScheme.surface else Color.White,
        dragHandle = {
            BottomSheetDefaults.DragHandle(
                color = if (isDark) Color(0x40FFFFFF) else Color(0x30000000)
            )
        },
        modifier = Modifier.testTag("app_menu_sheet")
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp)
                .padding(bottom = 36.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(18.dp)
        ) {
            // Profile Header Card
            Surface(
                shape = RoundedCornerShape(18.dp),
                color = if (isDark) MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f) else Color(0xFFF6F8FA),
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable {
                        onDismiss()
                        onViewProfile()
                    }
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box {
                        AsyncImage(
                            model = profile.avatarUrl,
                            contentDescription = "My Avatar",
                            contentScale = ContentScale.Crop,
                            modifier = Modifier
                                .size(54.dp)
                                .clip(CircleShape)
                        )
                        if (profile.onlineNow) {
                            Box(
                                modifier = Modifier
                                    .size(14.dp)
                                    .background(Color(0xFF22C55E), CircleShape)
                                    .align(Alignment.BottomEnd)
                            )
                        }
                    }

                    Spacer(modifier = Modifier.width(14.dp))

                    Column(modifier = Modifier.weight(1f)) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            Text(
                                text = profile.fullName,
                                fontWeight = FontWeight.Bold,
                                fontSize = 16.sp,
                                color = MaterialTheme.colorScheme.onSurface
                            )
                            if (profile.verificationBadge != VerificationBadge.NONE) {
                                VerifiedMark(badge = profile.verificationBadge, size = 16.dp)
                            }
                        }
                        Text(
                            text = "@${profile.username} • ${profile.faculty}",
                            fontSize = 13.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Text(
                            text = "${profile.followerCount} followers • ${profile.university}",
                            fontSize = 12.sp,
                            color = MaterialTheme.colorScheme.primary,
                            fontWeight = FontWeight.Medium
                        )
                    }

                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.ArrowForwardIos,
                        contentDescription = "Go to Profile",
                        tint = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.size(14.dp)
                    )
                }
            }

            // Section 1: Profile & Identity
            MenuSection(title = "Profile & Campus Identity") {
                MenuItemRow(
                    icon = Icons.Outlined.Person,
                    title = "View My Full Profile",
                    subtitle = "Badges, skills, endorsements & portfolio",
                    onClick = {
                        onDismiss()
                        onViewProfile()
                    }
                )
                MenuItemRow(
                    icon = Icons.Outlined.Edit,
                    title = "Edit Profile & Bio",
                    subtitle = "Update contact, academic level & socials",
                    onClick = {
                        onDismiss()
                        onEditProfile()
                    }
                )
                MenuItemRow(
                    icon = Icons.Outlined.Verified,
                    title = "Campus Verification",
                    subtitle = if (profile.verificationBadge != VerificationBadge.NONE) "Verified Campus Member" else "Get Verified Badge",
                    trailingText = if (profile.verificationBadge != VerificationBadge.NONE) "Active" else "Apply",
                    onClick = {
                        onShowToast("Student Verification status: ACTIVE ✦")
                    }
                )
            }

            // Section 2: Aluta Campus Commerce
            MenuSection(title = "Aluta Campus Market") {
                MenuItemRow(
                    icon = Icons.Outlined.Storefront,
                    title = "Browse Marketplace",
                    subtitle = "Books, electronics, hostel gear & fashion",
                    onClick = {
                        onDismiss()
                        onOpenMarket()
                    }
                )
                MenuItemRow(
                    icon = Icons.Outlined.AddShoppingCart,
                    title = "Post Item for Sale",
                    subtitle = "List your gear on campus with direct WhatsApp",
                    onClick = {
                        onDismiss()
                        onOpenPostItem()
                    }
                )
                MenuItemRow(
                    icon = Icons.Outlined.AccountBalanceWallet,
                    title = "Seller Hub & Paystack Escrow",
                    subtitle = if (profile.isSellerActive) "Store Active: ${profile.sellerStoreName}" else "Activate Merchant Account (₦2,500)",
                    trailingText = if (profile.isSellerActive) "Verified" else "Upgrade",
                    onClick = {
                        onDismiss()
                        onOpenBecomeSeller()
                    }
                )
            }

            // Section 3: Preferences & Experience
            MenuSection(title = "Experience & Appearance") {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(12.dp))
                        .clickable { onToggleTheme() }
                        .padding(vertical = 10.dp, horizontal = 12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .background(
                                if (isDark) Color(0xFF2A2035) else Color(0xFFF3E8FF),
                                CircleShape
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = if (isDark) Icons.Filled.DarkMode else Icons.Filled.LightMode,
                            contentDescription = "Theme",
                            tint = BlinkPink,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                    Spacer(modifier = Modifier.width(14.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Appearance Theme",
                            fontWeight = FontWeight.SemiBold,
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                        Text(
                            text = if (isDark) "Dark Mode (Vibrant Cyber)" else "Light Mode (Clean Campus)",
                            fontSize = 12.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                    Switch(
                        checked = isDark,
                        onCheckedChange = { onToggleTheme() },
                        colors = SwitchDefaults.colors(
                            checkedThumbColor = Color.White,
                            checkedTrackColor = BlinkPink
                        )
                    )
                }

                MenuItemRow(
                    icon = Icons.Outlined.Notifications,
                    title = "Campus Notifications",
                    subtitle = "Mentions, likes, orders & announcements",
                    onClick = {
                        onDismiss()
                        onOpenActivity()
                    }
                )
            }

            // Section 4: Campus Community & Support
            MenuSection(title = "Community & Safety") {
                MenuItemRow(
                    icon = Icons.Outlined.EmojiEvents,
                    title = "Leaderboard & Streaks",
                    subtitle = "Campus rankings and top contributor scores",
                    onClick = {
                        onDismiss()
                        onOpenLeaderboard()
                    }
                )
                MenuItemRow(
                    icon = Icons.Outlined.Shield,
                    title = "Aluta Safety & Protection",
                    subtitle = "Campus trust guidelines & verified meetups",
                    onClick = {
                        onShowToast("Aluta Safety: Always meet in well-lit public campus locations.")
                    }
                )
                MenuItemRow(
                    icon = Icons.Outlined.Share,
                    title = "Invite Classmates",
                    subtitle = "Earn 500 bonus rank points per student",
                    onClick = {
                        onShowToast("Invitation link copied to clipboard!")
                    }
                )
            }

            // Section 5: Account Session
            MenuSection(title = "Session") {
                MenuItemRow(
                    icon = Icons.Outlined.SwitchAccount,
                    title = "Switch Account",
                    subtitle = "Login to another student profile",
                    onClick = {
                        onDismiss()
                        onShowToast("Account switch triggered")
                    }
                )
                MenuItemRow(
                    icon = Icons.Outlined.NotificationsActive,
                    title = "Test Real-Life Notification",
                    subtitle = "Simulate a push notification when offline",
                    iconColor = BlinkPink,
                    onClick = {
                        onDismiss()
                        onSimulateNotification()
                    }
                )
                MenuItemRow(
                    icon = Icons.AutoMirrored.Filled.Logout,
                    title = "Log Out",
                    subtitle = "End your active session securely",
                    iconColor = Color(0xFFEF4444),
                    titleColor = Color(0xFFEF4444),
                    onClick = {
                        onDismiss()
                        onLogout()
                    }
                )
            }
        }
    }
}

@Composable
private fun MenuSection(
    title: String,
    content: @Composable ColumnScope.() -> Unit
) {
    Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Text(
            text = title.uppercase(),
            fontSize = 11.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.7f),
            letterSpacing = 0.8.sp,
            modifier = Modifier.padding(horizontal = 4.dp, vertical = 4.dp)
        )
        content()
    }
}

@Composable
private fun MenuItemRow(
    icon: ImageVector,
    title: String,
    subtitle: String,
    trailingText: String? = null,
    iconColor: Color = BlinkPink,
    titleColor: Color = Color.Unspecified,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .clickable { onClick() }
            .padding(vertical = 10.dp, horizontal = 12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(36.dp)
                .background(iconColor.copy(alpha = 0.12f), CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = title,
                tint = iconColor,
                modifier = Modifier.size(20.dp)
            )
        }
        Spacer(modifier = Modifier.width(14.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                fontWeight = FontWeight.SemiBold,
                fontSize = 14.sp,
                color = if (titleColor != Color.Unspecified) titleColor else MaterialTheme.colorScheme.onSurface
            )
            Text(
                text = subtitle,
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
        if (trailingText != null) {
            Surface(
                shape = RoundedCornerShape(100.dp),
                color = BlinkPink.copy(alpha = 0.15f),
                modifier = Modifier.padding(start = 8.dp)
            ) {
                Text(
                    text = trailingText,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    color = BlinkPink,
                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                )
            }
        } else {
            Icon(
                imageVector = Icons.AutoMirrored.Filled.ArrowForwardIos,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f),
                modifier = Modifier.size(13.dp)
            )
        }
    }
}
