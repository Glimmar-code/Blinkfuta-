package com.example.ui.screens

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AddPhotoAlternate
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.PhotoCamera
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
import com.example.data.models.ContactField
import com.example.data.models.UserProfile
import com.example.ui.components.CropAdjustDialog
import com.example.ui.theme.BlinkPink

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditProfileScreen(
    profile: UserProfile,
    onBack: () -> Unit,
    onSave: (UserProfile) -> Unit,
    isDark: Boolean
) {
    var fullName by remember { mutableStateOf(profile.fullName) }
    var username by remember { mutableStateOf(profile.username) }
    var avatarUrl by remember { mutableStateOf(profile.avatarUrl) }
    var coverPhotoUrl by remember { mutableStateOf(profile.coverPhotoUrl) }
    var headline by remember { mutableStateOf(profile.professionalHeadline) }
    var jobTitle by remember { mutableStateOf(profile.currentJobTitle) }
    var bio by remember { mutableStateOf(profile.bio) }
    var university by remember { mutableStateOf(profile.university) }
    var faculty by remember { mutableStateOf(profile.faculty) }
    var department by remember { mutableStateOf(profile.department) }
    var academicLevel by remember { mutableStateOf(profile.academicLevel) }
    var graduationYear by remember { mutableStateOf(profile.graduationYear) }
    var email by remember { mutableStateOf(profile.email.value) }
    var phone by remember { mutableStateOf(profile.phone.value) }

    var pendingCropUri by remember { mutableStateOf<Uri?>(null) }
    var isCropAvatar by remember { mutableStateOf(true) }

    val avatarPicker = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        uri?.let {
            pendingCropUri = it
            isCropAvatar = true
        }
    }

    val coverPicker = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        uri?.let {
            pendingCropUri = it
            isCropAvatar = false
        }
    }

    if (pendingCropUri != null) {
        CropAdjustDialog(
            imageUri = pendingCropUri!!,
            isCircle = isCropAvatar,
            onDismiss = { pendingCropUri = null },
            onCropComplete = { croppedUri ->
                if (isCropAvatar) {
                    avatarUrl = croppedUri.toString()
                } else {
                    coverPhotoUrl = croppedUri.toString()
                }
                pendingCropUri = null
            }
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Edit Student Profile", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.Close, contentDescription = "Close")
                    }
                },
                actions = {
                    TextButton(
                        onClick = {
                            val updated = profile.copy(
                                fullName = fullName,
                                username = username,
                                avatarUrl = avatarUrl,
                                coverPhotoUrl = coverPhotoUrl,
                                professionalHeadline = headline,
                                currentJobTitle = jobTitle,
                                bio = bio,
                                university = university,
                                faculty = faculty,
                                department = department,
                                academicLevel = academicLevel,
                                graduationYear = graduationYear,
                                email = ContactField(email, true),
                                phone = ContactField(phone, true)
                            )
                            onSave(updated)
                        }
                    ) {
                        Text("Save", fontWeight = FontWeight.Bold, color = BlinkPink, fontSize = 15.sp)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = MaterialTheme.colorScheme.surface)
            )
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            item {
                Text("Profile Photos (Upload JPEG / PNG)", fontWeight = FontWeight.Bold, fontSize = 15.sp)
            }

            // Cover Photo Upload Section
            item {
                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text("Cover Photo", fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(140.dp)
                            .clip(RoundedCornerShape(14.dp))
                            .background(MaterialTheme.colorScheme.surfaceVariant)
                            .clickable { coverPicker.launch("image/*") }
                    ) {
                        if (coverPhotoUrl.isNotEmpty()) {
                            AsyncImage(
                                model = coverPhotoUrl,
                                contentDescription = "Cover photo preview",
                                modifier = Modifier.fillMaxSize(),
                                contentScale = ContentScale.Crop
                            )
                        }
                        Box(
                            modifier = Modifier
                                .fillMaxSize()
                                .background(Color.Black.copy(alpha = 0.3f)),
                            contentAlignment = Alignment.Center
                        ) {
                            Row(
                                horizontalArrangement = Arrangement.spacedBy(8.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(Icons.Default.AddPhotoAlternate, contentDescription = null, tint = Color.White)
                                Text("Upload Cover (JPEG/PNG)", color = Color.White, fontWeight = FontWeight.SemiBold)
                            }
                        }
                    }
                }
            }

            // Avatar Upload Section
            item {
                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text("Avatar / Profile Picture", fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(80.dp)
                                .clip(CircleShape)
                                .background(MaterialTheme.colorScheme.surfaceVariant)
                                .clickable { avatarPicker.launch("image/*") },
                            contentAlignment = Alignment.Center
                        ) {
                            if (avatarUrl.isNotEmpty()) {
                                AsyncImage(
                                    model = avatarUrl,
                                    contentDescription = "Avatar preview",
                                    modifier = Modifier.fillMaxSize(),
                                    contentScale = ContentScale.Crop
                                )
                            }
                            Box(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .background(Color.Black.copy(alpha = 0.3f)),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(Icons.Default.PhotoCamera, contentDescription = null, tint = Color.White)
                            }
                        }
                        OutlinedButton(
                            onClick = { avatarPicker.launch("image/*") },
                            shape = RoundedCornerShape(12.dp)
                        ) {
                            Text("Upload Avatar (JPEG / PNG)")
                        }
                    }
                }
            }

            item {
                Spacer(modifier = Modifier.height(4.dp))
                Text("Personal Information", fontWeight = FontWeight.Bold, fontSize = 15.sp)
            }

            item {
                OutlinedTextField(
                    value = fullName,
                    onValueChange = { fullName = it },
                    label = { Text("Full Name") },
                    shape = RoundedCornerShape(14.dp),
                    modifier = Modifier.fillMaxWidth()
                )
            }

            item {
                OutlinedTextField(
                    value = username,
                    onValueChange = { username = it },
                    label = { Text("Username") },
                    shape = RoundedCornerShape(14.dp),
                    modifier = Modifier.fillMaxWidth()
                )
            }

            item {
                OutlinedTextField(
                    value = headline,
                    onValueChange = { headline = it },
                    label = { Text("Professional Headline") },
                    shape = RoundedCornerShape(14.dp),
                    modifier = Modifier.fillMaxWidth()
                )
            }

            item {
                OutlinedTextField(
                    value = jobTitle,
                    onValueChange = { jobTitle = it },
                    label = { Text("Current Role / Title") },
                    shape = RoundedCornerShape(14.dp),
                    modifier = Modifier.fillMaxWidth()
                )
            }

            item {
                OutlinedTextField(
                    value = bio,
                    onValueChange = { bio = it },
                    label = { Text("Bio") },
                    minLines = 3,
                    shape = RoundedCornerShape(14.dp),
                    modifier = Modifier.fillMaxWidth()
                )
            }

            item {
                Spacer(modifier = Modifier.height(6.dp))
                Text("Academic Background", fontWeight = FontWeight.Bold, fontSize = 15.sp)
            }

            item {
                OutlinedTextField(
                    value = university,
                    onValueChange = { university = it },
                    label = { Text("University / Institution") },
                    shape = RoundedCornerShape(14.dp),
                    modifier = Modifier.fillMaxWidth()
                )
            }

            item {
                OutlinedTextField(
                    value = faculty,
                    onValueChange = { faculty = it },
                    label = { Text("Faculty") },
                    shape = RoundedCornerShape(14.dp),
                    modifier = Modifier.fillMaxWidth()
                )
            }

            item {
                OutlinedTextField(
                    value = department,
                    onValueChange = { department = it },
                    label = { Text("Department / Course") },
                    shape = RoundedCornerShape(14.dp),
                    modifier = Modifier.fillMaxWidth()
                )
            }

            item {
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp), modifier = Modifier.fillMaxWidth()) {
                    OutlinedTextField(
                        value = academicLevel,
                        onValueChange = { academicLevel = it },
                        label = { Text("Level (e.g. 400L)") },
                        shape = RoundedCornerShape(14.dp),
                        modifier = Modifier.weight(1f)
                    )
                    OutlinedTextField(
                        value = graduationYear,
                        onValueChange = { graduationYear = it },
                        label = { Text("Graduation") },
                        shape = RoundedCornerShape(14.dp),
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            item {
                Spacer(modifier = Modifier.height(6.dp))
                Text("Contact Details", fontWeight = FontWeight.Bold, fontSize = 15.sp)
            }

            item {
                OutlinedTextField(
                    value = email,
                    onValueChange = { email = it },
                    label = { Text("Email Address") },
                    shape = RoundedCornerShape(14.dp),
                    modifier = Modifier.fillMaxWidth()
                )
            }

            item {
                OutlinedTextField(
                    value = phone,
                    onValueChange = { phone = it },
                    label = { Text("Phone Number") },
                    shape = RoundedCornerShape(14.dp),
                    modifier = Modifier.fillMaxWidth()
                )
            }

            item {
                Spacer(modifier = Modifier.height(16.dp))
                Button(
                    onClick = {
                        val updated = profile.copy(
                            fullName = fullName,
                            username = username,
                            avatarUrl = avatarUrl,
                            coverPhotoUrl = coverPhotoUrl,
                            professionalHeadline = headline,
                            currentJobTitle = jobTitle,
                            bio = bio,
                            university = university,
                            faculty = faculty,
                            department = department,
                            academicLevel = academicLevel,
                            graduationYear = graduationYear,
                            email = ContactField(email, true),
                            phone = ContactField(phone, true)
                        )
                        onSave(updated)
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = BlinkPink),
                    shape = RoundedCornerShape(100.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp)
                        .testTag("save_profile_btn")
                ) {
                    Text("Save Changes", fontSize = 15.sp, fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}
