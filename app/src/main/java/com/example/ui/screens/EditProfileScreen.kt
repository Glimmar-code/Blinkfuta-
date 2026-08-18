package com.example.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.models.ContactField
import com.example.data.models.UserProfile
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
