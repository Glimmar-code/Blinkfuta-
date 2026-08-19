package com.example.ui.screens

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.example.ui.components.BlinkMark
import com.example.ui.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@Composable
fun SplashScreen(
    onTimeout: () -> Unit
) {
    val infiniteTransition = rememberInfiniteTransition(label = "SplashPulse")
    val pulseScale by infiniteTransition.animateFloat(
        initialValue = 0.96f,
        targetValue = 1.04f,
        animationSpec = infiniteRepeatable(
            animation = tween(1200, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulse"
    )

    LaunchedEffect(Unit) {
        delay(1800)
        onTimeout()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.radialGradient(
                    colors = listOf(
                        Color(0xFF2E0A3C),
                        Color(0xFF160924),
                        DarkBackground
                    ),
                    radius = 1000f
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.padding(24.dp)
        ) {
            Box(modifier = Modifier.scale(pulseScale)) {
                BlinkMark(size = 76.dp, showText = false)
            }

            Spacer(modifier = Modifier.height(28.dp))

            Text(
                text = "BLINK",
                fontSize = 36.sp,
                fontWeight = FontWeight.Black,
                letterSpacing = 6.sp,
                color = Color.White
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = "CAMPUS SOCIAL & ALUTA MARKET",
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 2.5.sp,
                color = BlinkPink
            )

            Spacer(modifier = Modifier.height(48.dp))

            CircularProgressIndicator(
                modifier = Modifier.size(26.dp),
                color = BlinkPink,
                strokeWidth = 2.5.dp
            )
        }
    }
}

@Composable
fun OnboardingScreen(
    onSignInClick: () -> Unit,
    onSignUpClick: () -> Unit,
    onGoogleSignIn: (String) -> Unit
) {
    var showGoogleDialog by remember { mutableStateOf(false) }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.radialGradient(
                    colors = listOf(
                        Color(0xFF2C103C),
                        Color(0xFF130922),
                        DarkBackground
                    ),
                    radius = 900f
                )
            )
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .padding(horizontal = 24.dp, vertical = 16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            // Header
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 10.dp),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                BlinkMark(size = 36.dp, showText = true)
            }

            // Center Hero
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.padding(vertical = 12.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(96.dp)
                        .clip(CircleShape)
                        .background(
                            Brush.linearGradient(
                                listOf(BlinkPink, BlinkPurple, BlinkGold)
                            )
                        )
                        .padding(3.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .clip(CircleShape)
                            .background(DarkSurface),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.School,
                            contentDescription = "Campus",
                            tint = BlinkPink,
                            modifier = Modifier.size(46.dp)
                        )
                    }
                }

                Spacer(modifier = Modifier.height(24.dp))

                Text(
                    text = "Your University Life,\nAmplified.",
                    fontSize = 28.sp,
                    fontWeight = FontWeight.Black,
                    textAlign = TextAlign.Center,
                    lineHeight = 34.sp,
                    color = Color.White
                )

                Spacer(modifier = Modifier.height(12.dp))

                Text(
                    text = "Connect with students across Nigerian universities. Share live Reels, trade on ALUTA Market, and lead campus rankings.",
                    fontSize = 13.5.sp,
                    textAlign = TextAlign.Center,
                    lineHeight = 20.sp,
                    color = DarkTextSecondary,
                    modifier = Modifier.padding(horizontal = 12.dp)
                )

                Spacer(modifier = Modifier.height(20.dp))

                // Feature Highlights
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.padding(horizontal = 4.dp)
                ) {
                    FeaturePill(icon = Icons.Default.Stream, label = "Reels & Stories")
                    FeaturePill(icon = Icons.Default.Storefront, label = "Aluta Market")
                    FeaturePill(icon = Icons.Default.EmojiEvents, label = "Rankings")
                }
            }

            // Action Buttons
            Column(
                verticalArrangement = Arrangement.spacedBy(10.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 12.dp)
            ) {
                // Continue with Google / Gmail
                GoogleSignInButton(
                    text = "Continue with Google / Gmail",
                    onClick = { showGoogleDialog = true },
                    modifier = Modifier.testTag("onboarding_google_btn")
                )

                Button(
                    onClick = onSignUpClick,
                    colors = ButtonDefaults.buttonColors(containerColor = BlinkPink),
                    shape = RoundedCornerShape(100.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(50.dp)
                        .testTag("onboarding_signup_btn")
                ) {
                    Text(
                        "Create Student Account",
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                }

                OutlinedButton(
                    onClick = onSignInClick,
                    shape = RoundedCornerShape(100.dp),
                    border = BorderStroke(
                        1.dp,
                        Brush.horizontalGradient(listOf(BlinkPurple, BlinkLavender))
                    ),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(50.dp)
                        .testTag("onboarding_signin_btn")
                ) {
                    Text(
                        "Sign In with Email",
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                }
            }
        }
        
        if (showGoogleDialog) {
            GoogleSignInSimulatorDialog(
                onDismiss = { showGoogleDialog = false },
                onConfirm = { email ->
                    showGoogleDialog = false
                    onGoogleSignIn(email)
                }
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SignInScreen(
    onBack: () -> Unit,
    onSignInWithCredentials: (emailOrUsername: String, password: String, onResult: (Boolean, String?) -> Unit) -> Unit,
    onGoogleSignIn: (String) -> Unit,
    onForgotPassword: (email: String, onResult: (Boolean, String) -> Unit) -> Unit,
    onSwitchToSignUp: () -> Unit
) {
    var emailOrUsername by remember { mutableStateOf("golowosile@gmail.com") }
    var password by remember { mutableStateOf("password123") }
    var passwordVisible by remember { mutableStateOf(false) }
    var isSubmitting by remember { mutableStateOf(false) }
    var authError by remember { mutableStateOf<String?>(null) }
    var showForgotPasswordDialog by remember { mutableStateOf(false) }
    var showGoogleDialog by remember { mutableStateOf(false) }
    var isLoadingGoogle by remember { mutableStateOf(false) }
    val coroutineScope = rememberCoroutineScope()

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(DarkBackground)
    ) {
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .padding(horizontal = 24.dp),
            contentPadding = PaddingValues(top = 8.dp, bottom = 32.dp)
        ) {
            item {
                IconButton(
                    onClick = onBack,
                    modifier = Modifier
                        .size(40.dp)
                        .background(Color(0x33FFFFFF), CircleShape)
                        .testTag("signin_back_btn")
                ) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                        contentDescription = "Back",
                        tint = Color.White,
                        modifier = Modifier.size(20.dp)
                    )
                }

                Spacer(modifier = Modifier.height(20.dp))

                Text(
                    text = "Welcome back 👋",
                    fontSize = 28.sp,
                    fontWeight = FontWeight.Black,
                    color = Color.White
                )

                Spacer(modifier = Modifier.height(6.dp))

                Text(
                    text = "Sign in to access your student profile, live campus feed & Supabase sync.",
                    fontSize = 13.5.sp,
                    color = DarkTextSecondary,
                    lineHeight = 19.sp
                )

                Spacer(modifier = Modifier.height(20.dp))

                // Continue with Google / Gmail (Primary)
                GoogleSignInButton(
                    text = if (isLoadingGoogle) "Connecting to Google..." else "Continue with Gmail / Google",
                    onClick = {
                        isLoadingGoogle = true
                        coroutineScope.launch {
                            delay(300)
                            isLoadingGoogle = false
                            showGoogleDialog = true
                        }
                    },
                    modifier = Modifier.testTag("signin_google_btn")
                )

                Spacer(modifier = Modifier.height(18.dp))

                // Divider OR
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Box(modifier = Modifier.weight(1f).height(1.dp).background(DarkBorder))
                    Text(
                        text = "OR EMAIL & PASSWORD",
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = DarkTextSecondary,
                        modifier = Modifier.padding(horizontal = 12.dp)
                    )
                    Box(modifier = Modifier.weight(1f).height(1.dp).background(DarkBorder))
                }

                Spacer(modifier = Modifier.height(18.dp))

                // Error Banner if account is not found on Supabase or password invalid
                AnimatedVisibility(
                    visible = authError != null,
                    enter = fadeIn() + expandVertically(),
                    exit = fadeOut() + shrinkVertically()
                ) {
                    Surface(
                        color = Color(0x33FF4D4D),
                        shape = RoundedCornerShape(14.dp),
                        border = BorderStroke(1.dp, Color(0xFFFF4D4D)),
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(bottom = 16.dp)
                    ) {
                        Row(
                            modifier = Modifier.padding(14.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                imageVector = Icons.Default.ErrorOutline,
                                contentDescription = "Error",
                                tint = Color(0xFFFF6B6B),
                                modifier = Modifier.size(24.dp)
                            )
                            Spacer(modifier = Modifier.width(12.dp))
                            Text(
                                text = authError ?: "",
                                color = Color.White,
                                fontSize = 13.sp,
                                lineHeight = 18.sp,
                                fontWeight = FontWeight.Medium
                            )
                        }
                    }
                }

                // Email / Username field
                OutlinedTextField(
                    value = emailOrUsername,
                    onValueChange = {
                        emailOrUsername = it
                        authError = null
                    },
                    label = { Text("University Email or Username") },
                    leadingIcon = {
                        Icon(Icons.Default.Email, contentDescription = null, tint = BlinkPink, modifier = Modifier.size(20.dp))
                    },
                    isError = authError != null,
                    shape = RoundedCornerShape(16.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = BlinkPink,
                        unfocusedBorderColor = DarkBorder,
                        errorBorderColor = Color(0xFFFF4D4D),
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        focusedLabelColor = BlinkPink,
                        unfocusedLabelColor = DarkTextSecondary,
                        focusedContainerColor = DarkSurface,
                        unfocusedContainerColor = DarkSurface
                    ),
                    modifier = Modifier
                        .fillMaxWidth()
                        .testTag("signin_email_field")
                )

                Spacer(modifier = Modifier.height(14.dp))

                // Password field
                OutlinedTextField(
                    value = password,
                    onValueChange = {
                        password = it
                        authError = null
                    },
                    label = { Text("Password") },
                    leadingIcon = {
                        Icon(Icons.Default.Lock, contentDescription = null, tint = BlinkPink, modifier = Modifier.size(20.dp))
                    },
                    trailingIcon = {
                        IconButton(onClick = { passwordVisible = !passwordVisible }) {
                            Icon(
                                imageVector = if (passwordVisible) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                                contentDescription = "Toggle password",
                                tint = DarkTextSecondary,
                                modifier = Modifier.size(20.dp)
                            )
                        }
                    },
                    isError = authError != null,
                    visualTransformation = if (passwordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                    shape = RoundedCornerShape(16.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = BlinkPink,
                        unfocusedBorderColor = DarkBorder,
                        errorBorderColor = Color(0xFFFF4D4D),
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        focusedLabelColor = BlinkPink,
                        unfocusedLabelColor = DarkTextSecondary,
                        focusedContainerColor = DarkSurface,
                        unfocusedContainerColor = DarkSurface
                    ),
                    modifier = Modifier
                        .fillMaxWidth()
                        .testTag("signin_password_field")
                )

                // Forgot / Reset Password Button
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.End
                ) {
                    TextButton(
                        onClick = { showForgotPasswordDialog = true },
                        contentPadding = PaddingValues(vertical = 4.dp, horizontal = 0.dp)
                    ) {
                        Text(
                            text = "Forgot / Reset Password?",
                            color = BlinkLavender,
                            fontSize = 12.5.sp,
                            fontWeight = FontWeight.SemiBold
                        )
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Submit Button
                Button(
                    onClick = {
                        isSubmitting = true
                        authError = null
                        onSignInWithCredentials(emailOrUsername, password) { success, errorMsg ->
                            isSubmitting = false
                            if (!success) {
                                authError = errorMsg ?: "User unavailable or incorrect password."
                            }
                        }
                    },
                    enabled = !isSubmitting,
                    colors = ButtonDefaults.buttonColors(containerColor = BlinkPink),
                    shape = RoundedCornerShape(100.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp)
                        .shadow(8.dp, RoundedCornerShape(100.dp), ambientColor = BlinkPink)
                        .testTag("signin_submit_btn")
                ) {
                    if (isSubmitting) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(22.dp),
                            color = Color.White,
                            strokeWidth = 2.dp
                        )
                    } else {
                        Text(
                            "Sign In to Campus",
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        "Don't have an account?",
                        color = DarkTextSecondary,
                        fontSize = 13.5.sp
                    )
                    TextButton(onClick = onSwitchToSignUp) {
                        Text(
                            "Sign Up",
                            color = BlinkPink,
                            fontWeight = FontWeight.Bold,
                            fontSize = 13.5.sp
                        )
                    }
                }
            }
        }

        // Forgot / Reset Password Dialog
        if (showForgotPasswordDialog) {
            ForgotPasswordDialog(
                initialEmail = if (emailOrUsername.contains("@")) emailOrUsername else "",
                onDismiss = { showForgotPasswordDialog = false },
                onSendReset = onForgotPassword
            )
        }

        if (showGoogleDialog) {
            GoogleSignInSimulatorDialog(
                onDismiss = { showGoogleDialog = false },
                onConfirm = { email ->
                    showGoogleDialog = false
                    onGoogleSignIn(email)
                }
            )
        }
    }
}

/**
 * Forgot / Reset Password Dialog Modal
 */
@Composable
fun ForgotPasswordDialog(
    initialEmail: String,
    onDismiss: () -> Unit,
    onSendReset: (email: String, onResult: (Boolean, String) -> Unit) -> Unit
) {
    var resetEmail by remember { mutableStateOf(initialEmail) }
    var isSending by remember { mutableStateOf(false) }
    var statusMessage by remember { mutableStateOf<String?>(null) }
    var isSuccess by remember { mutableStateOf(false) }

    Dialog(onDismissRequest = onDismiss) {
        Surface(
            shape = RoundedCornerShape(24.dp),
            color = DarkSurface,
            border = BorderStroke(1.dp, DarkBorder),
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 8.dp)
        ) {
            Column(
                modifier = Modifier.padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Box(
                    modifier = Modifier
                        .size(56.dp)
                        .clip(CircleShape)
                        .background(Color(0x33FF0055)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.LockReset,
                        contentDescription = "Reset Password",
                        tint = BlinkPink,
                        modifier = Modifier.size(30.dp)
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                Text(
                    text = "Reset Your Password",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )

                Spacer(modifier = Modifier.height(6.dp))

                Text(
                    text = "Enter your registered university email or Gmail to receive a password reset link from Supabase.",
                    fontSize = 12.5.sp,
                    color = DarkTextSecondary,
                    textAlign = TextAlign.Center,
                    lineHeight = 18.sp
                )

                Spacer(modifier = Modifier.height(20.dp))

                if (statusMessage != null) {
                    Surface(
                        color = if (isSuccess) Color(0x3300E676) else Color(0x33FF4D4D),
                        shape = RoundedCornerShape(12.dp),
                        border = BorderStroke(1.dp, if (isSuccess) Color(0xFF00E676) else Color(0xFFFF4D4D)),
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(bottom = 16.dp)
                    ) {
                        Text(
                            text = statusMessage ?: "",
                            color = Color.White,
                            fontSize = 12.sp,
                            modifier = Modifier.padding(12.dp),
                            textAlign = TextAlign.Center
                        )
                    }
                }

                if (!isSuccess) {
                    OutlinedTextField(
                        value = resetEmail,
                        onValueChange = { resetEmail = it },
                        label = { Text("University / Gmail Address") },
                        leadingIcon = {
                            Icon(Icons.Default.Email, contentDescription = null, tint = BlinkPink, modifier = Modifier.size(18.dp))
                        },
                        shape = RoundedCornerShape(14.dp),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = BlinkPink,
                            unfocusedBorderColor = DarkBorder,
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White,
                            focusedLabelColor = BlinkPink,
                            unfocusedLabelColor = DarkTextSecondary,
                            focusedContainerColor = DarkBackground,
                            unfocusedContainerColor = DarkBackground
                        ),
                        modifier = Modifier.fillMaxWidth()
                    )

                    Spacer(modifier = Modifier.height(20.dp))

                    Button(
                        onClick = {
                            isSending = true
                            statusMessage = null
                            onSendReset(resetEmail) { success, msg ->
                                isSending = false
                                isSuccess = success
                                statusMessage = msg
                            }
                        },
                        enabled = !isSending && resetEmail.isNotBlank(),
                        colors = ButtonDefaults.buttonColors(containerColor = BlinkPink),
                        shape = RoundedCornerShape(100.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(48.dp)
                    ) {
                        if (isSending) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(20.dp),
                                color = Color.White,
                                strokeWidth = 2.dp
                            )
                        } else {
                            Text("Send Reset Link", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = Color.White)
                        }
                    }
                } else {
                    Button(
                        onClick = onDismiss,
                        colors = ButtonDefaults.buttonColors(containerColor = BlinkPink),
                        shape = RoundedCornerShape(100.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(48.dp)
                    ) {
                        Text("Back to Sign In", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = Color.White)
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))

                TextButton(onClick = onDismiss) {
                    Text("Cancel", color = DarkTextSecondary, fontSize = 13.sp)
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SignUpScreen(
    onBack: () -> Unit,
    onSuccess: (fullName: String, username: String, email: String, faculty: String) -> Unit,
    onGoogleSignUp: (String) -> Unit,
    onSwitchToSignIn: () -> Unit
) {
    var fullName by remember { mutableStateOf("Gbolahan Olowosile") }
    var username by remember { mutableStateOf("golowosile") }
    var email by remember { mutableStateOf("golowosile@gmail.com") }
    var password by remember { mutableStateOf("password123") }
    var faculty by remember { mutableStateOf("SIMME") }
    var isLoadingGoogle by remember { mutableStateOf(false) }
    var showGoogleDialog by remember { mutableStateOf(false) }
    var validationError by remember { mutableStateOf<String?>(null) }
    val coroutineScope = rememberCoroutineScope()

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(DarkBackground)
    ) {
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .padding(horizontal = 24.dp),
            contentPadding = PaddingValues(top = 8.dp, bottom = 32.dp)
        ) {
            item {
                IconButton(
                    onClick = onBack,
                    modifier = Modifier
                        .size(40.dp)
                        .background(Color(0x33FFFFFF), CircleShape)
                        .testTag("signup_back_btn")
                ) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                        contentDescription = "Back",
                        tint = Color.White,
                        modifier = Modifier.size(20.dp)
                    )
                }

                Spacer(modifier = Modifier.height(18.dp))

                Text(
                    text = "Join Blink Campus 🎓",
                    fontSize = 26.sp,
                    fontWeight = FontWeight.Black,
                    color = Color.White
                )

                Spacer(modifier = Modifier.height(6.dp))

                Text(
                    text = "Claim your student badge, start trading on Aluta Market, and connect.",
                    fontSize = 13.sp,
                    color = DarkTextSecondary
                )

                Spacer(modifier = Modifier.height(20.dp))

                // Fast Sign up with Google / Gmail
                GoogleSignInButton(
                    text = if (isLoadingGoogle) "Setting up with Google..." else "Sign up with Gmail / Google",
                    onClick = {
                        isLoadingGoogle = true
                        coroutineScope.launch {
                            delay(300)
                            isLoadingGoogle = false
                            showGoogleDialog = true
                        }
                    },
                    modifier = Modifier.testTag("signup_google_btn")
                )

                Spacer(modifier = Modifier.height(18.dp))

                // Divider OR
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Box(modifier = Modifier.weight(1f).height(1.dp).background(DarkBorder))
                    Text(
                        text = "OR ENTER DETAILS",
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = DarkTextSecondary,
                        modifier = Modifier.padding(horizontal = 12.dp)
                    )
                    Box(modifier = Modifier.weight(1f).height(1.dp).background(DarkBorder))
                }

                Spacer(modifier = Modifier.height(18.dp))

                if (validationError != null) {
                    Surface(
                        color = Color(0x33FF4D4D),
                        shape = RoundedCornerShape(12.dp),
                        border = BorderStroke(1.dp, Color(0xFFFF4D4D)),
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(bottom = 14.dp)
                    ) {
                        Text(
                            text = validationError ?: "",
                            color = Color.White,
                            fontSize = 12.5.sp,
                            modifier = Modifier.padding(12.dp)
                        )
                    }
                }

                OutlinedTextField(
                    value = fullName,
                    onValueChange = {
                        fullName = it
                        validationError = null
                    },
                    label = { Text("Full Name (e.g. Gbolahan Olowosile)") },
                    leadingIcon = {
                        Icon(Icons.Default.Person, contentDescription = null, tint = BlinkPink, modifier = Modifier.size(20.dp))
                    },
                    shape = RoundedCornerShape(14.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = BlinkPink,
                        unfocusedBorderColor = DarkBorder,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        focusedLabelColor = BlinkPink,
                        unfocusedLabelColor = DarkTextSecondary,
                        focusedContainerColor = DarkSurface,
                        unfocusedContainerColor = DarkSurface
                    ),
                    modifier = Modifier.fillMaxWidth()
                )

                Spacer(modifier = Modifier.height(12.dp))

                OutlinedTextField(
                    value = username,
                    onValueChange = {
                        username = it
                        validationError = null
                    },
                    label = { Text("Username (e.g. golowosile)") },
                    leadingIcon = {
                        Icon(Icons.Default.AlternateEmail, contentDescription = null, tint = BlinkPink, modifier = Modifier.size(20.dp))
                    },
                    shape = RoundedCornerShape(14.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = BlinkPink,
                        unfocusedBorderColor = DarkBorder,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        focusedLabelColor = BlinkPink,
                        unfocusedLabelColor = DarkTextSecondary,
                        focusedContainerColor = DarkSurface,
                        unfocusedContainerColor = DarkSurface
                    ),
                    modifier = Modifier.fillMaxWidth()
                )

                Spacer(modifier = Modifier.height(12.dp))

                OutlinedTextField(
                    value = email,
                    onValueChange = {
                        email = it
                        validationError = null
                    },
                    label = { Text("Student Email / Gmail") },
                    leadingIcon = {
                        Icon(Icons.Default.School, contentDescription = null, tint = BlinkPink, modifier = Modifier.size(20.dp))
                    },
                    shape = RoundedCornerShape(14.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = BlinkPink,
                        unfocusedBorderColor = DarkBorder,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        focusedLabelColor = BlinkPink,
                        unfocusedLabelColor = DarkTextSecondary,
                        focusedContainerColor = DarkSurface,
                        unfocusedContainerColor = DarkSurface
                    ),
                    modifier = Modifier.fillMaxWidth()
                )

                Spacer(modifier = Modifier.height(12.dp))

                OutlinedTextField(
                    value = password,
                    onValueChange = {
                        password = it
                        validationError = null
                    },
                    label = { Text("Password (at least 6 characters)") },
                    leadingIcon = {
                        Icon(Icons.Default.Lock, contentDescription = null, tint = BlinkPink, modifier = Modifier.size(20.dp))
                    },
                    visualTransformation = PasswordVisualTransformation(),
                    shape = RoundedCornerShape(14.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = BlinkPink,
                        unfocusedBorderColor = DarkBorder,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        focusedLabelColor = BlinkPink,
                        unfocusedLabelColor = DarkTextSecondary,
                        focusedContainerColor = DarkSurface,
                        unfocusedContainerColor = DarkSurface
                    ),
                    modifier = Modifier.fillMaxWidth()
                )

                Spacer(modifier = Modifier.height(14.dp))

                // Faculty selection chips
                Text(
                    text = "Faculty / School",
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    color = DarkTextSecondary
                )
                Spacer(modifier = Modifier.height(8.dp))
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    listOf("SIMME", "ENG", "LAW", "ARTS", "SCI").forEach { fac ->
                        val selected = faculty == fac
                        Surface(
                            shape = RoundedCornerShape(100.dp),
                            color = if (selected) BlinkPink else DarkSurface,
                            border = BorderStroke(
                                1.dp,
                                if (selected) BlinkPink else DarkBorder
                            ),
                            modifier = Modifier
                                .weight(1f)
                                .clickable { faculty = fac }
                        ) {
                            Text(
                                text = fac,
                                fontSize = 11.5.sp,
                                fontWeight = FontWeight.Bold,
                                textAlign = TextAlign.Center,
                                color = if (selected) Color.White else DarkTextSecondary,
                                modifier = Modifier.padding(vertical = 8.dp)
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(28.dp))

                Button(
                    onClick = {
                        if (fullName.isBlank()) {
                            validationError = "Please enter your full name."
                        } else if (username.isBlank()) {
                            validationError = "Please choose a campus username."
                        } else if (email.isBlank() || !email.contains("@")) {
                            validationError = "Please enter a valid email address."
                        } else if (password.length < 6) {
                            validationError = "Password must be at least 6 characters."
                        } else {
                            onSuccess(fullName, username, email, faculty)
                        }
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = BlinkPink),
                    shape = RoundedCornerShape(100.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp)
                        .shadow(8.dp, RoundedCornerShape(100.dp), ambientColor = BlinkPink)
                        .testTag("signup_submit_btn")
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.Center
                    ) {
                        Text(
                            "Next: Student Onboarding",
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                            contentDescription = null,
                            tint = Color.White,
                            modifier = Modifier.size(18.dp)
                        )
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        "Already on Blink?",
                        color = DarkTextSecondary,
                        fontSize = 13.5.sp
                    )
                    TextButton(onClick = onSwitchToSignIn) {
                        Text(
                            "Sign In",
                            color = BlinkPink,
                            fontWeight = FontWeight.Bold,
                            fontSize = 13.5.sp
                        )
                    }
                }
            }
        }
        
        if (showGoogleDialog) {
            GoogleSignInSimulatorDialog(
                onDismiss = { showGoogleDialog = false },
                onConfirm = { email ->
                    showGoogleDialog = false
                    onGoogleSignUp(email)
                }
            )
        }
    }
}

/**
 * Post-Signup Onboarding & Profile Setup Screen
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileSetupOnboardingScreen(
    studentName: String,
    studentUsername: String,
    onComplete: (university: String, department: String, level: String, bio: String, skills: List<String>) -> Unit
) {
    val universities = listOf(
        "University of Lagos (UNILAG)",
        "University of Benin (UNIBEN)",
        "Obafemi Awolowo University (OAU)",
        "University of Nigeria Nsukka (UNN)",
        "Ahmadu Bello University (ABU)",
        "Federal University of Technology Akure (FUTA)",
        "University of Ibadan (UI)",
        "Lagos State University (LASU)",
        "Covenant University"
    )
    val levels = listOf("100 Level", "200 Level", "300 Level", "400 Level", "500 Level", "Postgraduate")
    val interestOptions = listOf(
        "Product Design", "Coding & Software", "Aluta Market Commerce",
        "Photography", "Tech Meetups", "Gaming", "Content Creation",
        "Campus Politics", "Afrobeats", "Cryptocurrency", "Fashion & Thrift"
    )

    var selectedUniversity by remember { mutableStateOf(universities[0]) }
    var department by remember { mutableStateOf("Systems Engineering") }
    var selectedLevel by remember { mutableStateOf(levels[3]) }
    var bio by remember { mutableStateOf("Student creator on Blink 🚀 Building for campus life & trading on Aluta Market.") }
    val selectedInterests = remember { mutableStateListOf("Product Design", "Coding & Software", "Aluta Market Commerce") }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(DarkBackground)
    ) {
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .padding(horizontal = 24.dp),
            contentPadding = PaddingValues(top = 16.dp, bottom = 40.dp)
        ) {
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    BlinkMark(size = 32.dp, showText = true)
                    Surface(
                        shape = RoundedCornerShape(100.dp),
                        color = Color(0x33FF0055)
                    ) {
                        Text(
                            text = "Step 2 of 2: Onboarding",
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            color = BlinkPink,
                            modifier = Modifier.padding(horizontal = 10.dp, vertical = 5.dp)
                        )
                    }
                }

                Spacer(modifier = Modifier.height(24.dp))

                Text(
                    text = "Welcome, $studentName! 🎓",
                    fontSize = 26.sp,
                    fontWeight = FontWeight.Black,
                    color = Color.White
                )

                Spacer(modifier = Modifier.height(6.dp))

                Text(
                    text = "Set up your student profile so classmates and buyers can find you on Blink.",
                    fontSize = 13.5.sp,
                    color = DarkTextSecondary,
                    lineHeight = 19.sp
                )

                Spacer(modifier = Modifier.height(24.dp))

                // University selection
                Text(
                    text = "Select Your University",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                Spacer(modifier = Modifier.height(8.dp))
                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    items(universities) { uni ->
                        val isSelected = selectedUniversity == uni
                        Surface(
                            shape = RoundedCornerShape(100.dp),
                            color = if (isSelected) BlinkPink else DarkSurface,
                            border = BorderStroke(1.dp, if (isSelected) BlinkPink else DarkBorder),
                            modifier = Modifier.clickable { selectedUniversity = uni }
                        ) {
                            Text(
                                text = uni.substringBefore(" (").ifBlank { uni },
                                fontSize = 12.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = if (isSelected) Color.White else DarkTextSecondary,
                                modifier = Modifier.padding(horizontal = 14.dp, vertical = 8.dp)
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(18.dp))

                // Department
                OutlinedTextField(
                    value = department,
                    onValueChange = { department = it },
                    label = { Text("Department / Course") },
                    leadingIcon = {
                        Icon(Icons.Default.School, contentDescription = null, tint = BlinkPink, modifier = Modifier.size(20.dp))
                    },
                    shape = RoundedCornerShape(14.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = BlinkPink,
                        unfocusedBorderColor = DarkBorder,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        focusedLabelColor = BlinkPink,
                        unfocusedLabelColor = DarkTextSecondary,
                        focusedContainerColor = DarkSurface,
                        unfocusedContainerColor = DarkSurface
                    ),
                    modifier = Modifier.fillMaxWidth()
                )

                Spacer(modifier = Modifier.height(18.dp))

                // Academic Level
                Text(
                    text = "Academic Level",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                Spacer(modifier = Modifier.height(8.dp))
                Row(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    levels.take(4).forEach { lvl ->
                        val isSelected = selectedLevel == lvl
                        Surface(
                            shape = RoundedCornerShape(100.dp),
                            color = if (isSelected) BlinkPink else DarkSurface,
                            border = BorderStroke(1.dp, if (isSelected) BlinkPink else DarkBorder),
                            modifier = Modifier
                                .weight(1f)
                                .clickable { selectedLevel = lvl }
                        ) {
                            Text(
                                text = lvl.replace(" Level", "L"),
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Bold,
                                textAlign = TextAlign.Center,
                                color = if (isSelected) Color.White else DarkTextSecondary,
                                modifier = Modifier.padding(vertical = 8.dp)
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(18.dp))

                // Campus Interests / Skills
                Text(
                    text = "Pick Your Campus Interests & Skills",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                Spacer(modifier = Modifier.height(8.dp))
                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    items(interestOptions) { interest ->
                        val isSelected = selectedInterests.contains(interest)
                        Surface(
                            shape = RoundedCornerShape(100.dp),
                            color = if (isSelected) Color(0x33FF0055) else DarkSurface,
                            border = BorderStroke(1.dp, if (isSelected) BlinkPink else DarkBorder),
                            modifier = Modifier.clickable {
                                if (isSelected) selectedInterests.remove(interest)
                                else selectedInterests.add(interest)
                            }
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                if (isSelected) {
                                    Icon(
                                        imageVector = Icons.Default.Check,
                                        contentDescription = null,
                                        tint = BlinkPink,
                                        modifier = Modifier.size(14.dp)
                                    )
                                    Spacer(modifier = Modifier.width(4.dp))
                                }
                                Text(
                                    text = interest,
                                    fontSize = 12.sp,
                                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                                    color = if (isSelected) Color.White else DarkTextSecondary
                                )
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(18.dp))

                // Bio
                OutlinedTextField(
                    value = bio,
                    onValueChange = { bio = it },
                    label = { Text("Short Campus Bio") },
                    minLines = 3,
                    shape = RoundedCornerShape(14.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = BlinkPink,
                        unfocusedBorderColor = DarkBorder,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        focusedLabelColor = BlinkPink,
                        unfocusedLabelColor = DarkTextSecondary,
                        focusedContainerColor = DarkSurface,
                        unfocusedContainerColor = DarkSurface
                    ),
                    modifier = Modifier.fillMaxWidth()
                )

                Spacer(modifier = Modifier.height(30.dp))

                // Finish Setup Button
                Button(
                    onClick = {
                        onComplete(
                            selectedUniversity,
                            department,
                            selectedLevel,
                            bio,
                            selectedInterests.toList()
                        )
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = BlinkPink),
                    shape = RoundedCornerShape(100.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp)
                        .shadow(8.dp, RoundedCornerShape(100.dp), ambientColor = BlinkPink)
                        .testTag("complete_onboarding_btn")
                ) {
                    Text(
                        "Launch Blink Campus 🚀",
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                }
            }
        }
    }
}

/**
 * Premium Google / Gmail Multi-colored Sign In Button
 */
@Composable
fun GoogleSignInSimulatorDialog(
    onDismiss: () -> Unit,
    onConfirm: (String) -> Unit
) {
    var email by remember { mutableStateOf("") }
    Dialog(onDismissRequest = onDismiss) {
        Surface(
            shape = RoundedCornerShape(24.dp),
            color = DarkSurface,
            border = BorderStroke(1.dp, DarkBorder),
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.padding(24.dp)
            ) {
                GoogleLogoVector(modifier = Modifier.size(48.dp))
                Spacer(modifier = Modifier.height(16.dp))
                Text(
                    text = "Sign in with Google",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "Enter your Gmail address to continue to Blink Campus.",
                    fontSize = 13.5.sp,
                    color = DarkTextSecondary,
                    textAlign = TextAlign.Center
                )
                Spacer(modifier = Modifier.height(24.dp))
                OutlinedTextField(
                    value = email,
                    onValueChange = { email = it },
                    placeholder = { Text("example@gmail.com") },
                    singleLine = true,
                    keyboardOptions = androidx.compose.foundation.text.KeyboardOptions(
                        keyboardType = androidx.compose.ui.text.input.KeyboardType.Email
                    ),
                    shape = RoundedCornerShape(12.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = BlinkPink,
                        unfocusedBorderColor = DarkBorder,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White
                    ),
                    modifier = Modifier.fillMaxWidth()
                )
                Spacer(modifier = Modifier.height(24.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    OutlinedButton(
                        onClick = onDismiss,
                        modifier = Modifier.weight(1f),
                        colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White),
                        border = BorderStroke(1.dp, DarkBorder)
                    ) {
                        Text("Cancel")
                    }
                    Button(
                        onClick = {
                            if (email.isNotBlank()) {
                                onConfirm(email.trim())
                            }
                        },
                        modifier = Modifier.weight(1f),
                        colors = ButtonDefaults.buttonColors(containerColor = BlinkPink)
                    ) {
                        Text("Next")
                    }
                }
            }
        }
    }
}

@Composable
fun GoogleSignInButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        onClick = onClick,
        shape = RoundedCornerShape(100.dp),
        color = Color.White,
        shadowElevation = 4.dp,
        modifier = modifier
            .fillMaxWidth()
            .height(50.dp)
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center,
            modifier = Modifier.padding(horizontal = 16.dp)
        ) {
            GoogleLogoVector(modifier = Modifier.size(20.dp))
            Spacer(modifier = Modifier.width(12.dp))
            Text(
                text = text,
                color = Color(0xFF1F1F1F),
                fontSize = 14.5.sp,
                fontWeight = FontWeight.SemiBold
            )
        }
    }
}

/**
 * High quality crisp vector rendering of Google's Multi-Colored 'G' Icon
 */
@Composable
fun GoogleLogoVector(modifier: Modifier = Modifier) {
    Canvas(modifier = modifier) {
        val w = size.width
        val cx = w / 2f
        val cy = size.height / 2f
        val radius = w * 0.46f

        val blueColor = Color(0xFF4285F4)
        val greenColor = Color(0xFF34A853)
        val yellowColor = Color(0xFFFBBC05)
        val redColor = Color(0xFFEA4335)

        drawArc(
            color = redColor,
            startAngle = 180f + 40f,
            sweepAngle = 90f,
            useCenter = true,
            topLeft = Offset(cx - radius, cy - radius),
            size = Size(radius * 2, radius * 2)
        )
        drawArc(
            color = yellowColor,
            startAngle = 135f,
            sweepAngle = 85f,
            useCenter = true,
            topLeft = Offset(cx - radius, cy - radius),
            size = Size(radius * 2, radius * 2)
        )
        drawArc(
            color = greenColor,
            startAngle = 45f,
            sweepAngle = 90f,
            useCenter = true,
            topLeft = Offset(cx - radius, cy - radius),
            size = Size(radius * 2, radius * 2)
        )
        drawArc(
            color = blueColor,
            startAngle = -35f,
            sweepAngle = 80f,
            useCenter = true,
            topLeft = Offset(cx - radius, cy - radius),
            size = Size(radius * 2, radius * 2)
        )

        drawCircle(
            color = Color.White,
            radius = radius * 0.58f,
            center = Offset(cx, cy)
        )

        drawRect(
            color = blueColor,
            topLeft = Offset(cx - radius * 0.1f, cy - radius * 0.22f),
            size = Size(radius * 1.05f, radius * 0.44f)
        )
    }
}

@Composable
private fun FeaturePill(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    label: String
) {
    Surface(
        color = Color(0x22FFFFFF),
        shape = RoundedCornerShape(100.dp)
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp)
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = BlinkPink,
                modifier = Modifier.size(14.dp)
            )
            Text(
                text = label,
                fontSize = 11.sp,
                fontWeight = FontWeight.SemiBold,
                color = Color.White
            )
        }
    }
}
