package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.ui.components.*
import com.example.ui.screens.*
import com.example.ui.theme.BlinkTheme
import com.example.ui.theme.blinkBackgroundBrush
import com.example.viewmodel.AppDestination
import com.example.viewmodel.BlinkViewModel
import com.example.viewmodel.MainTab
import kotlinx.coroutines.flow.collectLatest

class MainActivity : ComponentActivity() {

    private val viewModel: BlinkViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            val uiState by viewModel.uiState.collectAsState()
            val snackbarHostState = remember { SnackbarHostState() }

            LaunchedEffect(Unit) {
                viewModel.snackBarMessages.collectLatest { message ->
                    snackbarHostState.showSnackbar(message)
                }
            }

            BlinkTheme(darkTheme = uiState.isDarkMode) {
                Scaffold(
                    snackbarHost = { SnackbarHost(snackbarHostState) },
                    contentWindowInsets = WindowInsets(0, 0, 0, 0),
                    modifier = Modifier.fillMaxSize()
                ) { innerPadding ->
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(innerPadding)
                            .background(blinkBackgroundBrush(uiState.isDarkMode))
                    ) {
                        AnimatedContent(
                            targetState = uiState.destination,
                            transitionSpec = {
                                fadeIn(animationSpec = tween(300)) togetherWith
                                        fadeOut(animationSpec = tween(300))
                            },
                            label = "AppDestinationTransition"
                        ) { destination ->
                            when (destination) {
                                AppDestination.SPLASH -> {
                                    SplashScreen(
                                        onTimeout = { viewModel.setDestination(AppDestination.ONBOARDING) }
                                    )
                                }

                                AppDestination.ONBOARDING -> {
                                    OnboardingScreen(
                                        onSignInClick = { viewModel.setDestination(AppDestination.SIGN_IN) },
                                        onSignUpClick = { viewModel.setDestination(AppDestination.SIGN_UP) },
                                        onGoogleSignIn = { viewModel.loginWithGoogle() }
                                    )
                                }

                                AppDestination.SIGN_IN -> {
                                    SignInScreen(
                                        onBack = { viewModel.setDestination(AppDestination.ONBOARDING) },
                                        onSuccess = { email -> viewModel.loginWithEmail(email) },
                                        onGoogleSignIn = { viewModel.loginWithGoogle() },
                                        onSwitchToSignUp = { viewModel.setDestination(AppDestination.SIGN_UP) }
                                    )
                                }

                                AppDestination.SIGN_UP -> {
                                    SignUpScreen(
                                        onBack = { viewModel.setDestination(AppDestination.ONBOARDING) },
                                        onSuccess = { name, user, email, fac ->
                                            viewModel.signUp(name, user, email, fac)
                                        },
                                        onGoogleSignUp = { viewModel.loginWithGoogle() },
                                        onSwitchToSignIn = { viewModel.setDestination(AppDestination.SIGN_IN) }
                                    )
                                }

                                AppDestination.MAIN -> {
                                    MainAppContent(
                                        uiState = uiState,
                                        viewModel = viewModel
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

@Composable
fun MainAppContent(
    uiState: com.example.viewmodel.BlinkUiState,
    viewModel: BlinkViewModel
) {
    // Handle back button presses for sub-views
    BackHandler(
        enabled = uiState.viewingProduct != null ||
                uiState.viewingProfile != null ||
                uiState.isPostItemOpen ||
                uiState.isBecomeSellerOpen ||
                uiState.isEditProfileOpen ||
                uiState.isMenuOpen ||
                uiState.activeConversationPartner != null
    ) {
        when {
            uiState.isMenuOpen -> viewModel.openMenu(false)
            uiState.isEditProfileOpen -> viewModel.openEditProfile(false)
            uiState.isBecomeSellerOpen -> viewModel.openBecomeSeller(false)
            uiState.isPostItemOpen -> viewModel.openPostItem(false)
            uiState.viewingProduct != null -> viewModel.closeProductDetail()
            uiState.viewingProfile != null -> viewModel.closeProfile()
            uiState.activeConversationPartner != null -> viewModel.closeConversation()
        }
    }

    Box(modifier = Modifier.fillMaxSize()) {
        // Main Tab Content
        Crossfade(targetState = uiState.selectedTab, label = "TabCrossfade") { tab ->
            when (tab) {
                MainTab.HOME -> {
                    FeedScreen(
                        posts = uiState.posts,
                        reels = uiState.reels,
                        stories = uiState.stories,
                        userAvatar = uiState.myProfile.avatarUrl,
                        currentSubTab = uiState.feedSubTab,
                        onSubTabChanged = { viewModel.setFeedSubTab(it) },
                        isDark = uiState.isDarkMode,
                        onLikePost = { viewModel.togglePostLike(it) },
                        onCommentPost = { viewModel.openCommentsForPost(it) },
                        onBookmarkPost = { viewModel.toggleBookmark(it) },
                        onSharePost = { viewModel.showToast("Link copied to clipboard!") },
                        onProfileClick = { viewModel.openProfile(it) },
                        onAddStoryClick = { viewModel.openCreatePost(true) },
                        onStoryClick = { story -> viewModel.showToast("Viewing story by @${story.username}") },
                        onOpenCreatePost = { viewModel.openCreatePost(true) },
                        onOpenActivity = { viewModel.openActivity(true) },
                        onOpenMenu = { viewModel.openMenu(true) },
                        onToggleTheme = { viewModel.toggleDarkMode() }
                    )
                }

                MainTab.SEARCH -> {
                    SearchScreen(
                        posts = uiState.posts,
                        onProfileClick = { viewModel.openProfile(it) },
                        onPostClick = { viewModel.openCommentsForPost(it.id) },
                        isDark = uiState.isDarkMode
                    )
                }

                MainTab.LEADERBOARD -> {
                    LeaderboardScreen(
                        users = uiState.leaderboardUsers,
                        onProfileClick = { viewModel.openProfile(it) },
                        isDark = uiState.isDarkMode
                    )
                }

                MainTab.MARKET -> {
                    MarketScreen(
                        items = uiState.marketItems,
                        isSellerActive = uiState.myProfile.isSellerActive,
                        onItemClick = { viewModel.openProductDetail(it) },
                        onOpenPostItem = { viewModel.openPostItem(true) },
                        onOpenBecomeSeller = { viewModel.openBecomeSeller(true) },
                        isDark = uiState.isDarkMode
                    )
                }

                MainTab.MESSAGES -> {
                    MessagesScreen(
                        conversations = uiState.conversations,
                        activePartner = uiState.activeConversationPartner,
                        onOpenConversation = { partner ->
                            viewModel.openChatWithUser(partner)
                        },
                        onCloseConversation = { viewModel.closeConversation() },
                        onSendMessage = { partner, text -> viewModel.sendMessage(partner, text) },
                        onProfileClick = { viewModel.openProfile(it) },
                        isDark = uiState.isDarkMode
                    )
                }
            }
        }

        // Floating Bottom Nav (Visible when on main views, hide when viewing sub-pages)
        val shouldShowBottomBar = uiState.viewingProduct == null &&
                uiState.viewingProfile == null &&
                !uiState.isPostItemOpen &&
                !uiState.isBecomeSellerOpen &&
                !uiState.isEditProfileOpen &&
                !uiState.isConversationFullScreen &&
                (uiState.selectedTab != MainTab.HOME || uiState.feedSubTab == 0)

        if (shouldShowBottomBar) {
            FloatingBottomBar(
                currentTab = uiState.selectedTab,
                onTabSelected = { viewModel.setTab(it) },
                isDark = uiState.isDarkMode,
                modifier = Modifier.align(Alignment.BottomCenter)
            )
        }

        // Sub-screen Overlays: Product Detail
        AnimatedVisibility(
            visible = uiState.viewingProduct != null,
            enter = slideInHorizontally(initialOffsetX = { it }) + fadeIn(),
            exit = slideOutHorizontally(targetOffsetX = { it }) + fadeOut()
        ) {
            uiState.viewingProduct?.let { product ->
                ProductDetailScreen(
                    item = product,
                    onBack = { viewModel.closeProductDetail() },
                    onDirectMessage = { partner, sellerName, sellerAvatar ->
                        viewModel.openChatWithUser(partner, sellerName, sellerAvatar)
                    },
                    onSellerProfileClick = { viewModel.openProfile(it) },
                    isDark = uiState.isDarkMode
                )
            }
        }

        // Sub-screen Overlays: User Profile
        AnimatedVisibility(
            visible = uiState.viewingProfile != null,
            enter = slideInHorizontally(initialOffsetX = { it }) + fadeIn(),
            exit = slideOutHorizontally(targetOffsetX = { it }) + fadeOut()
        ) {
            uiState.viewingProfile?.let { profile ->
                ProfileScreen(
                    profile = profile,
                    isMe = profile.username == uiState.myProfile.username,
                    userPosts = uiState.posts,
                    onBack = { viewModel.closeProfile() },
                    onEditProfileClick = { viewModel.openEditProfile(true) },
                    onDirectMessage = { partner -> viewModel.openChatWithUser(partner) },
                    onEndorseSkill = { skill -> viewModel.endorseSkill(skill) },
                    onLikePost = { viewModel.togglePostLike(it) },
                    onCommentPost = { viewModel.openCommentsForPost(it) },
                    onBookmarkPost = { viewModel.toggleBookmark(it) },
                    onSharePost = { viewModel.showToast("Post link copied!") },
                    isDark = uiState.isDarkMode
                )
            }
        }

        // Sub-screen Overlays: Post Item Screen
        AnimatedVisibility(
            visible = uiState.isPostItemOpen,
            enter = slideInVertically(initialOffsetY = { it }) + fadeIn(),
            exit = slideOutVertically(targetOffsetY = { it }) + fadeOut()
        ) {
            PostItemScreen(
                onBack = { viewModel.openPostItem(false) },
                onSubmit = { title, price, category, condition, description, imageUrl ->
                    viewModel.addMarketItem(title, price, category, condition, description, imageUrl)
                },
                isDark = uiState.isDarkMode
            )
        }

        // Sub-screen Overlays: Become Seller Screen
        AnimatedVisibility(
            visible = uiState.isBecomeSellerOpen,
            enter = slideInVertically(initialOffsetY = { it }) + fadeIn(),
            exit = slideOutVertically(targetOffsetY = { it }) + fadeOut()
        ) {
            BecomeSellerScreen(
                onBack = { viewModel.openBecomeSeller(false) },
                onSuccess = { storeName, phone, whatsapp, state, city ->
                    viewModel.activateSellerAccount(storeName, phone, whatsapp, state, city)
                },
                isDark = uiState.isDarkMode
            )
        }

        // Sub-screen Overlays: Edit Profile Screen
        AnimatedVisibility(
            visible = uiState.isEditProfileOpen,
            enter = slideInVertically(initialOffsetY = { it }) + fadeIn(),
            exit = slideOutVertically(targetOffsetY = { it }) + fadeOut()
        ) {
            EditProfileScreen(
                profile = uiState.myProfile,
                onBack = { viewModel.openEditProfile(false) },
                onSave = { updated ->
                    viewModel.updateMyProfile(updated)
                },
                isDark = uiState.isDarkMode
            )
        }

        // Modals: Comments Modal Sheet
        if (uiState.activeCommentsPostId != null) {
            CommentSheet(
                comments = uiState.comments,
                isDark = uiState.isDarkMode,
                onDismiss = { viewModel.openCommentsForPost(null) },
                onSendComment = { text ->
                    uiState.activeCommentsPostId?.let { postId ->
                        viewModel.addComment(postId, text)
                    }
                },
                onProfileClick = { username ->
                    viewModel.openCommentsForPost(null)
                    viewModel.openProfile(username)
                }
            )
        }

        // Modals: Activity Sheet
        if (uiState.isActivityOpen) {
            ActivitySheet(
                activities = uiState.activities,
                onDismiss = { viewModel.openActivity(false) },
                onProfileClick = { username ->
                    viewModel.openActivity(false)
                    viewModel.openProfile(username)
                },
                isDark = uiState.isDarkMode
            )
        }

        // Modals: Create Post Sheet
        if (uiState.isCreatePostOpen) {
            CreatePostSheet(
                profile = uiState.myProfile,
                onDismiss = { viewModel.openCreatePost(false) },
                onSubmitPost = { text, faculty, imageUri ->
                    viewModel.addPost(text, faculty, imageUri)
                },
                isDark = uiState.isDarkMode
            )
        }

        // Modals: 3-Dot App Menu Sheet
        if (uiState.isMenuOpen) {
            AppMenuSheet(
                profile = uiState.myProfile,
                isDark = uiState.isDarkMode,
                onDismiss = { viewModel.openMenu(false) },
                onViewProfile = { viewModel.openProfile("you") },
                onEditProfile = { viewModel.openEditProfile(true) },
                onOpenMarket = { viewModel.setTab(MainTab.MARKET) },
                onOpenPostItem = { viewModel.openPostItem(true) },
                onOpenBecomeSeller = { viewModel.openBecomeSeller(true) },
                onOpenLeaderboard = { viewModel.setTab(MainTab.LEADERBOARD) },
                onOpenActivity = { viewModel.openActivity(true) },
                onToggleTheme = { viewModel.toggleDarkMode() },
                onLogout = { viewModel.logout() },
                onShowToast = { viewModel.showToast(it) }
            )
        }
    }
}
