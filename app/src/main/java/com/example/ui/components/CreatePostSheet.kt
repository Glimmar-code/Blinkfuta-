package com.example.ui.components

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.example.data.models.PollOption
import com.example.data.models.PostPoll
import com.example.data.models.UserProfile
import com.example.ui.theme.BlinkPink
import com.example.ui.theme.BlinkPurple

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CreatePostSheet(
    profile: UserProfile,
    onDismiss: () -> Unit,
    onSubmitPost: (
        text: String,
        faculty: String,
        imageUri: String?,
        videoUri: String?,
        tags: List<String>,
        mentions: List<String>,
        poll: PostPoll?,
        isReel: Boolean
    ) -> Unit,
    isDark: Boolean
) {
    var text by remember { mutableStateOf("") }
    var selectedFaculty by remember { mutableStateOf(profile.faculty) }
    var selectedImageUri by remember { mutableStateOf<String?>(null) }
    var selectedVideoUri by remember { mutableStateOf<String?>(null) }
    var isReel by remember { mutableStateOf(false) }

    // Tags & Mentions state
    val selectedTags = remember { mutableStateListOf<String>() }
    val selectedMentions = remember { mutableStateListOf<String>() }

    // Poll state
    var showPollCreator by remember { mutableStateOf(false) }
    var pollQuestion by remember { mutableStateOf("") }
    val pollOptions = remember { mutableStateListOf("Option 1", "Option 2") }

    val faculties = listOf("SIMME", "ENGINEERING", "LAW", "ARTS", "SCIENCE", "MEDICINE")
    val popularTags = listOf("#UNILAG", "#CampusLife", "#TechVibes", "#Exams", "#AlutaMarket", "#Gist", "#Sports")
    val peerMentions = listOf("kemi_eng", "tunde_tech", "zainab_law", "chidi_bio", "bola_med", "david_simme")

    // Image Picker Launcher
    val photoPickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.PickVisualMedia()
    ) { uri: Uri? ->
        if (uri != null) {
            selectedImageUri = uri.toString()
            selectedVideoUri = null
        }
    }

    // Video Picker Launcher
    val videoPickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.PickVisualMedia()
    ) { uri: Uri? ->
        if (uri != null) {
            selectedVideoUri = uri.toString()
            selectedImageUri = null
            isReel = true
        }
    }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        containerColor = MaterialTheme.colorScheme.surface,
        shape = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp),
        dragHandle = {
            Box(
                modifier = Modifier
                    .padding(vertical = 10.dp)
                    .width(40.dp)
                    .height(4.dp)
                    .clip(RoundedCornerShape(2.dp))
                    .background(MaterialTheme.colorScheme.outlineVariant)
            )
        }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.85f)
                .padding(bottom = 16.dp)
        ) {
            // Top Bar
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 4.dp)
            ) {
                IconButton(onClick = onDismiss) {
                    Icon(Icons.Default.Close, contentDescription = "Close")
                }

                Text(
                    text = if (isReel) "Create Campus Reel" else "Create Campus Post",
                    fontWeight = FontWeight.Bold,
                    fontSize = 16.sp
                )

                Button(
                    onClick = {
                        if (text.isNotBlank() || selectedImageUri != null || selectedVideoUri != null || (showPollCreator && pollQuestion.isNotBlank())) {
                            val pollObj = if (showPollCreator && pollQuestion.isNotBlank()) {
                                PostPoll(
                                    question = pollQuestion.trim(),
                                    options = pollOptions.filter { it.isNotBlank() }.mapIndexed { idx, optText ->
                                        PollOption(id = "opt_$idx", text = optText.trim(), votes = 0)
                                    }
                                )
                            } else null

                            onSubmitPost(
                                text.trim(),
                                selectedFaculty,
                                selectedImageUri,
                                selectedVideoUri,
                                selectedTags.toList(),
                                selectedMentions.toList(),
                                pollObj,
                                isReel
                            )
                        }
                    },
                    enabled = text.isNotBlank() || selectedImageUri != null || selectedVideoUri != null || (showPollCreator && pollQuestion.isNotBlank()),
                    colors = ButtonDefaults.buttonColors(containerColor = BlinkPink),
                    shape = RoundedCornerShape(100.dp),
                    contentPadding = PaddingValues(horizontal = 22.dp, vertical = 8.dp),
                    modifier = Modifier.testTag("submit_create_post_btn")
                ) {
                    Text("Post", fontWeight = FontWeight.Bold, fontSize = 14.sp)
                }
            }

            HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f))

            Column(
                modifier = Modifier
                    .weight(1f)
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 16.dp, vertical = 12.dp)
            ) {
                // Author row
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                    modifier = Modifier.padding(bottom = 12.dp)
                ) {
                    AsyncImage(
                        model = profile.avatarUrl,
                        contentDescription = profile.fullName,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier
                            .size(44.dp)
                            .clip(CircleShape)
                            .border(1.5.dp, BlinkPink, CircleShape)
                    )

                    Column(modifier = Modifier.weight(1f)) {
                        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                            Text(
                                text = profile.fullName,
                                fontWeight = FontWeight.Bold,
                                fontSize = 14.sp,
                                color = MaterialTheme.colorScheme.onSurface
                            )
                            Icon(
                                imageVector = Icons.Default.Verified,
                                contentDescription = "Verified",
                                tint = BlinkPink,
                                modifier = Modifier.size(15.dp)
                            )
                        }
                        Text(
                            text = "Posting to @${profile.username} • ${profile.university}",
                            fontSize = 11.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }

                    // Reel badge toggle
                    Surface(
                        shape = RoundedCornerShape(100.dp),
                        color = if (isReel) BlinkPurple.copy(alpha = 0.15f) else MaterialTheme.colorScheme.surfaceVariant,
                        border = if (isReel) androidx.compose.foundation.BorderStroke(1.dp, BlinkPurple) else null,
                        modifier = Modifier.clickable { isReel = !isReel }
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(4.dp),
                            modifier = Modifier.padding(horizontal = 10.dp, vertical = 5.dp)
                        ) {
                            Icon(
                                imageVector = if (isReel) Icons.Default.Videocam else Icons.Outlined.VideoLibrary,
                                contentDescription = "Reel toggle",
                                tint = if (isReel) BlinkPurple else MaterialTheme.colorScheme.onSurfaceVariant,
                                modifier = Modifier.size(16.dp)
                            )
                            Text(
                                text = if (isReel) "Reel ✦" else "Post",
                                fontSize = 11.5.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = if (isReel) BlinkPurple else MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }

                // Faculty selector pills
                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    modifier = Modifier.fillMaxWidth().padding(bottom = 12.dp)
                ) {
                    items(faculties) { fac ->
                        val isSelected = selectedFaculty.equals(fac, ignoreCase = true)
                        Surface(
                            shape = RoundedCornerShape(100.dp),
                            color = if (isSelected) BlinkPink else MaterialTheme.colorScheme.surfaceVariant,
                            modifier = Modifier.clickable { selectedFaculty = fac }
                        ) {
                            Text(
                                text = fac,
                                fontSize = 11.sp,
                                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                                color = if (isSelected) Color.White else MaterialTheme.colorScheme.onSurface,
                                modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp)
                            )
                        }
                    }
                }

                // Main Text Input
                TextField(
                    value = text,
                    onValueChange = { text = it },
                    placeholder = {
                        Text(
                            text = if (isReel) "Add a caption for your campus reel..." else "What's happening on campus? Share faculty updates, gist, exam tips, or start a discussion...",
                            color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.7f),
                            fontSize = 15.sp,
                            lineHeight = 22.sp
                        )
                    },
                    keyboardOptions = androidx.compose.foundation.text.KeyboardOptions(
                        capitalization = androidx.compose.ui.text.input.KeyboardCapitalization.Sentences,
                        autoCorrectEnabled = true
                    ),
                    colors = TextFieldDefaults.colors(
                        focusedContainerColor = Color.Transparent,
                        unfocusedContainerColor = Color.Transparent,
                        focusedIndicatorColor = Color.Transparent,
                        unfocusedIndicatorColor = Color.Transparent
                    ),
                    modifier = Modifier
                        .fillMaxWidth()
                        .heightIn(min = 90.dp)
                        .testTag("create_post_text_field")
                )

                // Media Preview (Image or Video)
                if (selectedImageUri != null || selectedVideoUri != null) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(200.dp)
                            .padding(vertical = 8.dp)
                            .clip(RoundedCornerShape(16.dp))
                            .background(Color.Black.copy(alpha = 0.05f))
                    ) {
                        if (selectedImageUri != null) {
                            AsyncImage(
                                model = selectedImageUri,
                                contentDescription = "Selected post photo",
                                contentScale = ContentScale.Crop,
                                modifier = Modifier.fillMaxSize()
                            )
                        } else {
                            // Video preview card
                            Box(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .background(Color(0xFF1E1E2C)),
                                contentAlignment = Alignment.Center
                            ) {
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Icon(
                                        imageVector = Icons.Default.PlayCircleFilled,
                                        contentDescription = "Video attached",
                                        tint = BlinkPink,
                                        modifier = Modifier.size(54.dp)
                                    )
                                    Spacer(modifier = Modifier.height(6.dp))
                                    Text("Video Attached (Campus Reel)", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                                }
                            }
                        }

                        // Remove media button
                        IconButton(
                            onClick = {
                                selectedImageUri = null
                                selectedVideoUri = null
                            },
                            modifier = Modifier
                                .align(Alignment.TopEnd)
                                .padding(8.dp)
                                .size(32.dp)
                                .background(Color.Black.copy(alpha = 0.6f), CircleShape)
                        ) {
                            Icon(Icons.Default.Close, contentDescription = "Remove photo", tint = Color.White, modifier = Modifier.size(18.dp))
                        }
                    }
                }

                // Poll Creator Section
                AnimatedVisibility(visible = showPollCreator) {
                    Card(
                        shape = RoundedCornerShape(16.dp),
                        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)),
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 8.dp)
                    ) {
                        Column(modifier = Modifier.padding(14.dp)) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.SpaceBetween,
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                                    Icon(Icons.Default.Poll, contentDescription = null, tint = BlinkPink, modifier = Modifier.size(18.dp))
                                    Text("Campus Poll", fontWeight = FontWeight.Bold, fontSize = 13.5.sp)
                                }
                                IconButton(onClick = { showPollCreator = false }, modifier = Modifier.size(24.dp)) {
                                    Icon(Icons.Default.Close, contentDescription = "Remove poll", modifier = Modifier.size(16.dp))
                                }
                            }

                            Spacer(modifier = Modifier.height(8.dp))

                            OutlinedTextField(
                                value = pollQuestion,
                                onValueChange = { pollQuestion = it },
                                placeholder = { Text("Ask a question...") },
                                keyboardOptions = androidx.compose.foundation.text.KeyboardOptions(
                                    capitalization = androidx.compose.ui.text.input.KeyboardCapitalization.Sentences,
                                    autoCorrectEnabled = true
                                ),
                                shape = RoundedCornerShape(12.dp),
                                modifier = Modifier.fillMaxWidth(),
                                singleLine = true
                            )

                            Spacer(modifier = Modifier.height(8.dp))

                            pollOptions.forEachIndexed { idx, opt ->
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                                    modifier = Modifier.padding(vertical = 3.dp)
                                ) {
                                    OutlinedTextField(
                                        value = opt,
                                        onValueChange = { newVal -> pollOptions[idx] = newVal },
                                        placeholder = { Text("Option ${idx + 1}") },
                                        keyboardOptions = androidx.compose.foundation.text.KeyboardOptions(
                                            capitalization = androidx.compose.ui.text.input.KeyboardCapitalization.Sentences,
                                            autoCorrectEnabled = true
                                        ),
                                        shape = RoundedCornerShape(10.dp),
                                        modifier = Modifier.weight(1f),
                                        singleLine = true
                                    )
                                    if (pollOptions.size > 2) {
                                        IconButton(onClick = { pollOptions.removeAt(idx) }, modifier = Modifier.size(32.dp)) {
                                            Icon(Icons.Default.RemoveCircleOutline, contentDescription = "Delete option", tint = Color.Red.copy(alpha = 0.7f))
                                        }
                                    }
                                }
                            }

                            if (pollOptions.size < 4) {
                                TextButton(
                                    onClick = { pollOptions.add("Option ${pollOptions.size + 1}") },
                                    modifier = Modifier.padding(top = 4.dp)
                                ) {
                                    Icon(Icons.Default.Add, contentDescription = null, modifier = Modifier.size(16.dp), tint = BlinkPink)
                                    Spacer(modifier = Modifier.width(4.dp))
                                    Text("+ Add Option", color = BlinkPink, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                                }
                            }
                        }
                    }
                }

                // Selected Tags & Mentions Display
                if (selectedTags.isNotEmpty() || selectedMentions.isNotEmpty()) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 6.dp),
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        selectedTags.forEach { tag ->
                            Surface(
                                shape = RoundedCornerShape(100.dp),
                                color = BlinkPink.copy(alpha = 0.12f),
                                modifier = Modifier.clickable { selectedTags.remove(tag) }
                            ) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                                ) {
                                    Text(tag, color = BlinkPink, fontWeight = FontWeight.SemiBold, fontSize = 12.sp)
                                    Spacer(modifier = Modifier.width(4.dp))
                                    Icon(Icons.Default.Close, contentDescription = "Remove", tint = BlinkPink, modifier = Modifier.size(12.dp))
                                }
                            }
                        }

                        selectedMentions.forEach { mention ->
                            Surface(
                                shape = RoundedCornerShape(100.dp),
                                color = BlinkPurple.copy(alpha = 0.12f),
                                modifier = Modifier.clickable { selectedMentions.remove(mention) }
                            ) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                                ) {
                                    Text("@$mention", color = BlinkPurple, fontWeight = FontWeight.SemiBold, fontSize = 12.sp)
                                    Spacer(modifier = Modifier.width(4.dp))
                                    Icon(Icons.Default.Close, contentDescription = "Remove", tint = BlinkPurple, modifier = Modifier.size(12.dp))
                                }
                            }
                        }
                    }
                }

                // Popular Tags suggestions
                Text(
                    text = "Add Tags:",
                    fontSize = 11.5.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(top = 8.dp, bottom = 4.dp)
                )
                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    modifier = Modifier.fillMaxWidth().padding(bottom = 8.dp)
                ) {
                    items(popularTags) { tag ->
                        val isAdded = selectedTags.contains(tag)
                        Surface(
                            shape = RoundedCornerShape(100.dp),
                            color = if (isAdded) BlinkPink else MaterialTheme.colorScheme.surfaceVariant,
                            modifier = Modifier.clickable {
                                if (isAdded) selectedTags.remove(tag) else selectedTags.add(tag)
                            }
                        ) {
                            Text(
                                text = tag,
                                fontSize = 11.sp,
                                fontWeight = if (isAdded) FontWeight.Bold else FontWeight.Normal,
                                color = if (isAdded) Color.White else MaterialTheme.colorScheme.onSurface,
                                modifier = Modifier.padding(horizontal = 10.dp, vertical = 5.dp)
                            )
                        }
                    }
                }

                // Mention Friends suggestions
                Text(
                    text = "Mention Friends:",
                    fontSize = 11.5.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(top = 4.dp, bottom = 4.dp)
                )
                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    modifier = Modifier.fillMaxWidth().padding(bottom = 12.dp)
                ) {
                    items(peerMentions) { user ->
                        val isAdded = selectedMentions.contains(user)
                        Surface(
                            shape = RoundedCornerShape(100.dp),
                            color = if (isAdded) BlinkPurple else MaterialTheme.colorScheme.surfaceVariant,
                            modifier = Modifier.clickable {
                                if (isAdded) selectedMentions.remove(user) else selectedMentions.add(user)
                            }
                        ) {
                            Text(
                                text = "@$user",
                                fontSize = 11.sp,
                                fontWeight = if (isAdded) FontWeight.Bold else FontWeight.Normal,
                                color = if (isAdded) Color.White else MaterialTheme.colorScheme.onSurface,
                                modifier = Modifier.padding(horizontal = 10.dp, vertical = 5.dp)
                            )
                        }
                    }
                }
            }

            HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f))

            // Bottom Action Bar with Photo Picker, Video Picker, Poll, Tag, Mention
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceAround,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 8.dp, vertical = 8.dp)
            ) {
                // Photo Picker Button
                Surface(
                    shape = RoundedCornerShape(12.dp),
                    color = if (selectedImageUri != null) BlinkPink.copy(alpha = 0.15f) else Color.Transparent,
                    modifier = Modifier.clickable {
                        photoPickerLauncher.launch(
                            PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly)
                        )
                    }
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 8.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.PhotoLibrary,
                            contentDescription = "Pick Photo from gallery",
                            tint = if (selectedImageUri != null) BlinkPink else MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier = Modifier.size(20.dp)
                        )
                        Text(
                            text = "Photo",
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Medium,
                            color = if (selectedImageUri != null) BlinkPink else MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }

                // Video / Reel Picker Button
                Surface(
                    shape = RoundedCornerShape(12.dp),
                    color = if (selectedVideoUri != null) BlinkPurple.copy(alpha = 0.15f) else Color.Transparent,
                    modifier = Modifier.clickable {
                        videoPickerLauncher.launch(
                            PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.VideoOnly)
                        )
                    }
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 8.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Videocam,
                            contentDescription = "Pick Video from gallery",
                            tint = if (selectedVideoUri != null) BlinkPurple else MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier = Modifier.size(20.dp)
                        )
                        Text(
                            text = "Video",
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Medium,
                            color = if (selectedVideoUri != null) BlinkPurple else MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }

                // Poll Button
                Surface(
                    shape = RoundedCornerShape(12.dp),
                    color = if (showPollCreator) BlinkPink.copy(alpha = 0.15f) else Color.Transparent,
                    modifier = Modifier.clickable { showPollCreator = !showPollCreator }
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 8.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Poll,
                            contentDescription = "Attach Poll",
                            tint = if (showPollCreator) BlinkPink else MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier = Modifier.size(20.dp)
                        )
                        Text(
                            text = "Poll",
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Medium,
                            color = if (showPollCreator) BlinkPink else MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }

                // Tag # Button
                Surface(
                    shape = RoundedCornerShape(12.dp),
                    color = Color.Transparent,
                    modifier = Modifier.clickable {
                        if (popularTags.isNotEmpty()) {
                            val nextTag = popularTags.firstOrNull { !selectedTags.contains(it) }
                            if (nextTag != null) selectedTags.add(nextTag)
                        }
                    }
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 8.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Tag,
                            contentDescription = "Add Tag",
                            tint = MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier = Modifier.size(20.dp)
                        )
                        Text("Tag", fontSize = 12.sp, fontWeight = FontWeight.Medium, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                }

                // Mention @ Button
                Surface(
                    shape = RoundedCornerShape(12.dp),
                    color = Color.Transparent,
                    modifier = Modifier.clickable {
                        if (peerMentions.isNotEmpty()) {
                            val nextMention = peerMentions.firstOrNull { !selectedMentions.contains(it) }
                            if (nextMention != null) selectedMentions.add(nextMention)
                        }
                    }
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 8.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.AlternateEmail,
                            contentDescription = "Mention user",
                            tint = MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier = Modifier.size(20.dp)
                        )
                        Text("Mention", fontSize = 12.sp, fontWeight = FontWeight.Medium, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                }
            }
        }
    }
}
