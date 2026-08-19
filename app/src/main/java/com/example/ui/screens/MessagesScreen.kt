package com.example.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
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
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.example.data.models.ChatConversation
import com.example.data.models.ChatMessage
import com.example.data.models.VerificationBadge
import com.example.ui.components.FacultyBadge
import com.example.ui.components.VerifiedMark
import com.example.ui.theme.BlinkOnlineGreen
import com.example.ui.theme.BlinkPink
import com.example.ui.theme.BlinkPurple

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MessagesScreen(
    conversations: List<ChatConversation>,
    activePartner: String?,
    onOpenConversation: (String) -> Unit,
    onCloseConversation: () -> Unit,
    onSendMessage: (String, String) -> Unit,
    onProfileClick: (String) -> Unit,
    isDark: Boolean
) {
    if (activePartner != null) {
        val convo = conversations.find { it.partnerUsername == activePartner }
        if (convo != null) {
            ChatConversationView(
                convo = convo,
                onBack = onCloseConversation,
                onSendMessage = { text -> onSendMessage(convo.partnerUsername, text) },
                onProfileClick = onProfileClick,
                isDark = isDark
            )
            return
        }
    }

    var searchQuery by remember { mutableStateOf("") }
    val filteredConvos = remember(searchQuery, conversations) {
        conversations.filter {
            searchQuery.isBlank() ||
                    it.partnerName.contains(searchQuery, ignoreCase = true) ||
                    it.partnerUsername.contains(searchQuery, ignoreCase = true) ||
                    it.lastMessage.contains(searchQuery, ignoreCase = true)
        }
    }

    LazyColumn(
        contentPadding = PaddingValues(bottom = 120.dp),
        modifier = Modifier
            .fillMaxSize()
            .testTag("messages_screen")
    ) {
        // Header
        item {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(start = 20.dp, end = 20.dp, top = 48.dp, bottom = 12.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.ChatBubble,
                            contentDescription = "Messages",
                            tint = BlinkPink,
                            modifier = Modifier.size(26.dp)
                        )
                        Text(
                            text = "Direct Messages",
                            fontSize = 22.sp,
                            fontWeight = FontWeight.Black,
                            color = MaterialTheme.colorScheme.onBackground
                        )
                    }

                    Surface(
                        shape = RoundedCornerShape(100.dp),
                        color = BlinkPink.copy(alpha = 0.15f)
                    ) {
                        Text(
                            text = "${conversations.size} Chats",
                            fontSize = 11.5.sp,
                            fontWeight = FontWeight.Bold,
                            color = BlinkPink,
                            modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                        )
                    }
                }
            }
        }

        // Search Bar
        item {
            Surface(
                color = if (isDark) MaterialTheme.colorScheme.surfaceVariant else Color(0xFFEFEFF4),
                shape = RoundedCornerShape(100.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 6.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.padding(horizontal = 16.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Search,
                        contentDescription = "Search Chats",
                        tint = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    TextField(
                        value = searchQuery,
                        onValueChange = { searchQuery = it },
                        placeholder = {
                            Text(
                                "Search student messages & sellers...",
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                fontSize = 13.sp
                            )
                        },
                        keyboardOptions = androidx.compose.foundation.text.KeyboardOptions(
                            imeAction = androidx.compose.ui.text.input.ImeAction.Search,
                            autoCorrectEnabled = true
                        ),
                        singleLine = true,
                        colors = TextFieldDefaults.colors(
                            focusedContainerColor = Color.Transparent,
                            unfocusedContainerColor = Color.Transparent,
                            focusedIndicatorColor = Color.Transparent,
                            unfocusedIndicatorColor = Color.Transparent
                        ),
                        modifier = Modifier.weight(1f)
                    )
                }
            }
        }

        // Active Online Students Header
        item {
            Text(
                text = "Online on Campus",
                fontSize = 13.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(start = 20.dp, top = 14.dp, bottom = 8.dp)
            )
        }

        // Conversations List
        items(filteredConvos, key = { it.id }) { convo ->
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 4.dp)
                    .clickable { onOpenConversation(convo.partnerUsername) }
                    .testTag("conversation_item_${convo.partnerUsername}")
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(14.dp)
                ) {
                    // Avatar with online status dot
                    Box(
                        contentAlignment = Alignment.BottomEnd,
                        modifier = Modifier.size(48.dp)
                    ) {
                        AsyncImage(
                            model = convo.partnerAvatar,
                            contentDescription = convo.partnerName,
                            contentScale = ContentScale.Crop,
                            modifier = Modifier
                                .fillMaxSize()
                                .clip(CircleShape)
                        )

                        if (convo.isOnline) {
                            Box(
                                modifier = Modifier
                                    .size(13.dp)
                                    .clip(CircleShape)
                                    .background(BlinkOnlineGreen)
                                    .border(2.dp, MaterialTheme.colorScheme.surface, CircleShape)
                            )
                        }
                    }

                    Spacer(modifier = Modifier.width(12.dp))

                    Column(modifier = Modifier.weight(1f)) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.SpaceBetween,
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(6.dp)
                            ) {
                                Text(
                                    text = convo.partnerName,
                                    fontSize = 14.5.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = MaterialTheme.colorScheme.onSurface
                                )
                                if (convo.verificationBadge != VerificationBadge.NONE) {
                                    VerifiedMark(badge = convo.verificationBadge, size = 13.dp)
                                } else if (convo.isVerified) {
                                    VerifiedMark(badge = VerificationBadge.BLUE, size = 13.dp)
                                }
                            }

                            Text(
                                text = convo.lastMessageTime,
                                fontSize = 11.sp,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }

                        Spacer(modifier = Modifier.height(4.dp))

                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.SpaceBetween,
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text(
                                text = convo.lastMessage,
                                fontSize = 13.sp,
                                color = if (convo.unreadCount > 0) MaterialTheme.colorScheme.onSurface else MaterialTheme.colorScheme.onSurfaceVariant,
                                fontWeight = if (convo.unreadCount > 0) FontWeight.Bold else FontWeight.Normal,
                                maxLines = 1,
                                modifier = Modifier.weight(1f)
                            )

                            if (convo.unreadCount > 0) {
                                Box(
                                    contentAlignment = Alignment.Center,
                                    modifier = Modifier
                                        .size(20.dp)
                                        .clip(CircleShape)
                                        .background(BlinkPink)
                                ) {
                                    Text(
                                        text = "${convo.unreadCount}",
                                        fontSize = 10.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = Color.White
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

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChatConversationView(
    convo: ChatConversation,
    onBack: () -> Unit,
    onSendMessage: (String) -> Unit,
    onProfileClick: (String) -> Unit,
    isDark: Boolean
) {
    var messageText by remember { mutableStateOf("") }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(10.dp),
                        modifier = Modifier.clickable { onProfileClick(convo.partnerUsername) }
                    ) {
                        AsyncImage(
                            model = convo.partnerAvatar,
                            contentDescription = convo.partnerName,
                            contentScale = ContentScale.Crop,
                            modifier = Modifier
                                .size(38.dp)
                                .clip(CircleShape)
                        )
                        Column {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(4.dp)
                            ) {
                                Text(convo.partnerName, fontSize = 15.sp, fontWeight = FontWeight.Bold)
                                if (convo.verificationBadge != VerificationBadge.NONE) {
                                    VerifiedMark(badge = convo.verificationBadge, size = 13.dp)
                                } else if (convo.isVerified) {
                                    VerifiedMark(badge = VerificationBadge.BLUE, size = 13.dp)
                                }
                            }
                            Text(
                                text = if (convo.isOnline) "Active Now" else "Last seen ${convo.lastSeen}",
                                fontSize = 11.sp,
                                color = if (convo.isOnline) BlinkOnlineGreen else MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    IconButton(onClick = { onProfileClick(convo.partnerUsername) }) {
                        Icon(Icons.Default.Info, contentDescription = "User Info")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = MaterialTheme.colorScheme.surface)
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            // Message Bubbles List
            LazyColumn(
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
            ) {
                items(convo.messages, key = { it.id }) { msg ->
                    ChatBubble(message = msg, isDark = isDark)
                }
            }

            // Input Bar at bottom
            Surface(
                color = MaterialTheme.colorScheme.surface,
                shadowElevation = 8.dp,
                modifier = Modifier
                    .fillMaxWidth()
                    .border(1.dp, MaterialTheme.colorScheme.outlineVariant)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp)
                ) {
                    IconButton(onClick = {}) {
                        Icon(Icons.Default.AddPhotoAlternate, contentDescription = "Attach image", tint = BlinkPink)
                    }

                    TextField(
                        value = messageText,
                        onValueChange = { messageText = it },
                        placeholder = {
                            Text("Type a message...", fontSize = 13.5.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                        },
                        keyboardOptions = androidx.compose.foundation.text.KeyboardOptions(
                            capitalization = androidx.compose.ui.text.input.KeyboardCapitalization.Sentences,
                            imeAction = androidx.compose.ui.text.input.ImeAction.Send,
                            autoCorrectEnabled = true
                        ),
                        keyboardActions = androidx.compose.foundation.text.KeyboardActions(
                            onSend = {
                                if (messageText.isNotBlank()) {
                                    onSendMessage(messageText.trim())
                                    messageText = ""
                                }
                            }
                        ),
                        colors = TextFieldDefaults.colors(
                            focusedContainerColor = Color.Transparent,
                            unfocusedContainerColor = Color.Transparent,
                            focusedIndicatorColor = Color.Transparent,
                            unfocusedIndicatorColor = Color.Transparent
                        ),
                        modifier = Modifier
                            .weight(1f)
                            .testTag("chat_input_field")
                    )

                    IconButton(
                        onClick = {
                            if (messageText.isNotBlank()) {
                                onSendMessage(messageText.trim())
                                messageText = ""
                            }
                        },
                        enabled = messageText.isNotBlank()
                    ) {
                        Icon(
                            imageVector = Icons.Default.Send,
                            contentDescription = "Send",
                            tint = if (messageText.isNotBlank()) BlinkPink else MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun ChatBubble(
    message: ChatMessage,
    isDark: Boolean
) {
    val isMe = message.isFromMe

    Column(
        horizontalAlignment = if (isMe) Alignment.End else Alignment.Start,
        modifier = Modifier.fillMaxWidth()
    ) {
        Surface(
            shape = RoundedCornerShape(
                topStart = 16.dp,
                topEnd = 16.dp,
                bottomStart = if (isMe) 16.dp else 2.dp,
                bottomEnd = if (isMe) 2.dp else 16.dp
            ),
            color = if (isMe) BlinkPink else (if (isDark) MaterialTheme.colorScheme.surfaceVariant else Color(0xFFE9ECEF)),
            modifier = Modifier.widthIn(max = 280.dp)
        ) {
            Column(modifier = Modifier.padding(horizontal = 14.dp, vertical = 10.dp)) {
                Text(
                    text = message.text,
                    fontSize = 13.5.sp,
                    color = if (isMe) Color.White else MaterialTheme.colorScheme.onSurface,
                    lineHeight = 18.sp
                )
            }
        }

        Spacer(modifier = Modifier.height(2.dp))

        Text(
            text = message.timestamp,
            fontSize = 10.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(horizontal = 4.dp)
        )
    }
}
