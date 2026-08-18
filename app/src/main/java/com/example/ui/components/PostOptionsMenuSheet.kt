package com.example.ui.components

import androidx.compose.foundation.BorderStroke
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.ClipboardManager
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.example.data.models.FeedPost
import com.example.ui.theme.BlinkPink
import com.example.ui.theme.BlinkPurple

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PostOptionsMenuSheet(
    post: FeedPost,
    isAuthor: Boolean,
    isDark: Boolean,
    onDismiss: () -> Unit,
    onToggleSave: () -> Unit,
    onShare: () -> Unit,
    onDelete: () -> Unit,
    onReport: (reason: String) -> Unit,
    onMuteUser: (username: String) -> Unit
) {
    val clipboardManager: ClipboardManager = LocalClipboardManager.current
    var showReportDialog by remember { mutableStateOf(false) }
    var showDeleteConfirmDialog by remember { mutableStateOf(false) }
    var showMuteConfirmDialog by remember { mutableStateOf(false) }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = if (isDark) MaterialTheme.colorScheme.surface else Color.White,
        shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 8.dp)
                .padding(bottom = 28.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            // Header handle / author preview
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 8.dp)
            ) {
                Column {
                    Text(
                        text = "Post by @${post.author}",
                        fontWeight = FontWeight.Bold,
                        fontSize = 15.sp,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    Text(
                        text = "${formatNumber(post.viewsCount)} views • ${post.timeAgo}",
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }

                IconButton(onClick = onDismiss) {
                    Icon(
                        imageVector = Icons.Default.Close,
                        contentDescription = "Close",
                        tint = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)

            Spacer(modifier = Modifier.height(4.dp))

            // 1. Save / Bookmark
            OptionItemRow(
                icon = if (post.isBookmarked) Icons.Filled.Bookmark else Icons.Outlined.BookmarkBorder,
                iconTint = if (post.isBookmarked) BlinkPurple else MaterialTheme.colorScheme.onSurface,
                title = if (post.isBookmarked) "Remove from Saved" else "Save / Bookmark Post",
                subtitle = "Access from your Profile Saved tab anytime",
                onClick = {
                    onToggleSave()
                    onDismiss()
                }
            )

            // 2. Share / Copy Link
            OptionItemRow(
                icon = Icons.Outlined.Share,
                iconTint = MaterialTheme.colorScheme.onSurface,
                title = "Share Post & Copy Link",
                subtitle = "Share to campus groups or copy post URL",
                onClick = {
                    clipboardManager.setText(AnnotatedString("https://blink.campus/post/${post.id}"))
                    onShare()
                    onDismiss()
                }
            )

            // 3. Copy Post Text
            OptionItemRow(
                icon = Icons.Outlined.ContentCopy,
                iconTint = MaterialTheme.colorScheme.onSurface,
                title = "Copy Post Text",
                subtitle = "Copy the caption content to clipboard",
                onClick = {
                    clipboardManager.setText(AnnotatedString(post.text))
                    onDismiss()
                }
            )

            // 4. Delete Post (if author or user)
            OptionItemRow(
                icon = Icons.Outlined.Delete,
                iconTint = Color(0xFFFF5252),
                title = "Delete Post",
                subtitle = if (isAuthor) "Permanently remove your post from feed" else "Remove post from your feed view",
                onClick = {
                    showDeleteConfirmDialog = true
                }
            )

            // 5. Mute User
            if (!isAuthor) {
                OptionItemRow(
                    icon = Icons.Outlined.VolumeOff,
                    iconTint = Color(0xFFFF9800),
                    title = "Mute @${post.author}",
                    subtitle = "Hide all posts and updates from this user",
                    onClick = {
                        showMuteConfirmDialog = true
                    }
                )

                // 6. Report Post
                OptionItemRow(
                    icon = Icons.Outlined.Flag,
                    iconTint = Color(0xFFFF5252),
                    title = "Report Post",
                    subtitle = "Flag for campus moderation review",
                    onClick = {
                        showReportDialog = true
                    }
                )
            }
        }
    }

    // Delete Confirmation Dialog
    if (showDeleteConfirmDialog) {
        AlertDialog(
            onDismissRequest = { showDeleteConfirmDialog = false },
            title = { Text("Delete Post?", fontWeight = FontWeight.Bold) },
            text = { Text("Are you sure you want to delete this post? This action cannot be undone.") },
            confirmButton = {
                Button(
                    onClick = {
                        showDeleteConfirmDialog = false
                        onDelete()
                        onDismiss()
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFFF5252))
                ) {
                    Text("Delete", color = Color.White)
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteConfirmDialog = false }) {
                    Text("Cancel")
                }
            }
        )
    }

    // Mute Confirmation Dialog
    if (showMuteConfirmDialog) {
        AlertDialog(
            onDismissRequest = { showMuteConfirmDialog = false },
            title = { Text("Mute @${post.author}?", fontWeight = FontWeight.Bold) },
            text = { Text("You won't see posts or stories from @${post.author} in your feed anymore.") },
            confirmButton = {
                Button(
                    onClick = {
                        showMuteConfirmDialog = false
                        onMuteUser(post.author)
                        onDismiss()
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = BlinkPink)
                ) {
                    Text("Mute User", color = Color.White)
                }
            },
            dismissButton = {
                TextButton(onClick = { showMuteConfirmDialog = false }) {
                    Text("Cancel")
                }
            }
        )
    }

    // Report Dialog with Reasons
    if (showReportDialog) {
        ReportPostDialog(
            author = post.author,
            onDismiss = { showReportDialog = false },
            onSubmitReport = { reason ->
                showReportDialog = false
                onReport(reason)
                onDismiss()
            }
        )
    }
}

@Composable
fun ReportPostDialog(
    author: String,
    onDismiss: () -> Unit,
    onSubmitReport: (String) -> Unit
) {
    val reportReasons = listOf(
        "Spam or misleading campus ad",
        "Harassment, hate speech or bullying",
        "Exam malpractice or academic dishonesty",
        "Inappropriate content or explicit media",
        "Scam / Fake seller on Aluta Market",
        "Intellectual property violation"
    )
    var selectedReason by remember { mutableStateOf(reportReasons[0]) }

    Dialog(onDismissRequest = onDismiss) {
        Surface(
            shape = RoundedCornerShape(24.dp),
            color = MaterialTheme.colorScheme.surface,
            border = BorderStroke(1.dp, MaterialTheme.colorScheme.outlineVariant),
            modifier = Modifier.fillMaxWidth().padding(horizontal = 8.dp)
        ) {
            Column(
                modifier = Modifier.padding(22.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Box(
                    modifier = Modifier
                        .size(52.dp)
                        .clip(CircleShape)
                        .background(Color(0x22FF5252)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Flag,
                        contentDescription = "Report",
                        tint = Color(0xFFFF5252),
                        modifier = Modifier.size(28.dp)
                    )
                }

                Spacer(modifier = Modifier.height(14.dp))

                Text(
                    text = "Report Post by @$author",
                    fontWeight = FontWeight.Bold,
                    fontSize = 18.sp,
                    color = MaterialTheme.colorScheme.onSurface
                )

                Spacer(modifier = Modifier.height(6.dp))

                Text(
                    text = "Help us keep Blink safe and productive for university students. Select a reason:",
                    fontSize = 12.5.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(16.dp))

                Column(
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    reportReasons.forEach { reason ->
                        val isSelected = selectedReason == reason
                        Surface(
                            shape = RoundedCornerShape(12.dp),
                            color = if (isSelected) Color(0x33FF0055) else MaterialTheme.colorScheme.surfaceVariant,
                            border = BorderStroke(
                                1.dp,
                                if (isSelected) BlinkPink else MaterialTheme.colorScheme.outlineVariant
                            ),
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable { selectedReason = reason }
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 14.dp, vertical = 10.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                RadioButton(
                                    selected = isSelected,
                                    onClick = { selectedReason = reason },
                                    colors = RadioButtonDefaults.colors(selectedColor = BlinkPink)
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(
                                    text = reason,
                                    fontSize = 12.5.sp,
                                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                                    color = MaterialTheme.colorScheme.onSurface
                                )
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(20.dp))

                Button(
                    onClick = { onSubmitReport(selectedReason) },
                    colors = ButtonDefaults.buttonColors(containerColor = BlinkPink),
                    shape = RoundedCornerShape(100.dp),
                    modifier = Modifier.fillMaxWidth().height(48.dp)
                ) {
                    Text("Submit Report", fontWeight = FontWeight.Bold, color = Color.White)
                }

                Spacer(modifier = Modifier.height(8.dp))

                TextButton(onClick = onDismiss) {
                    Text("Cancel", color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }
        }
    }
}

@Composable
private fun OptionItemRow(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    iconTint: Color,
    title: String,
    subtitle: String,
    onClick: () -> Unit
) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(14.dp),
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .clickable { onClick() }
            .padding(vertical = 10.dp, horizontal = 8.dp)
    ) {
        Box(
            modifier = Modifier
                .size(40.dp)
                .clip(CircleShape)
                .background(iconTint.copy(alpha = 0.12f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = title,
                tint = iconTint,
                modifier = Modifier.size(20.dp)
            )
        }

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onSurface
            )
            Text(
                text = subtitle,
                fontSize = 11.5.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}
