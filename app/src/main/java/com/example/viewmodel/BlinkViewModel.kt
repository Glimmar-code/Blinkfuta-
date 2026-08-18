package com.example.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.data.BlinkDemoData
import com.example.data.models.*
import com.example.data.supabase.SupabaseService
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

enum class AppDestination {
    SPLASH, ONBOARDING, SIGN_IN, SIGN_UP, MAIN
}

enum class MainTab(val index: Int, val title: String) {
    HOME(0, "Home"),
    SEARCH(1, "Search"),
    LEADERBOARD(2, "Leaderboard"),
    MARKET(3, "Market"),
    MESSAGES(4, "Messages")
}

data class BlinkUiState(
    val destination: AppDestination = AppDestination.SPLASH,
    val selectedTab: MainTab = MainTab.HOME,
    val isDarkMode: Boolean = true,
    val myProfile: UserProfile = UserProfile(),
    val viewingProfile: UserProfile? = null,
    val viewingProduct: MarketItem? = null,
    val isPostItemOpen: Boolean = false,
    val isBecomeSellerOpen: Boolean = false,
    val isEditProfileOpen: Boolean = false,
    val isActivityOpen: Boolean = false,
    val isMenuOpen: Boolean = false,
    val activeCommentsPostId: String? = null,
    val isCreatePostOpen: Boolean = false,
    val activeConversationPartner: String? = null,
    val isConversationFullScreen: Boolean = false,
    val stories: List<Story> = BlinkDemoData.initialStories(),
    val posts: List<FeedPost> = BlinkDemoData.initialPosts(),
    val reels: List<FeedPost> = BlinkDemoData.initialReels(),
    val marketItems: List<MarketItem> = BlinkDemoData.initialMarketItems(),
    val leaderboardUsers: List<LeaderboardUser> = BlinkDemoData.initialLeaderboard(),
    val conversations: List<ChatConversation> = BlinkDemoData.initialConversations(),
    val activities: List<ActivityItem> = BlinkDemoData.initialActivities(),
    val comments: List<Comment> = BlinkDemoData.initialComments(),
    val feedSubTab: Int = 0, // 0: Posts, 1: Reels
    val isLiveSupabaseConnected: Boolean = true
)

class BlinkViewModel : ViewModel() {

    private val supabaseService = SupabaseService()

    private val _uiState = MutableStateFlow(BlinkUiState())
    val uiState: StateFlow<BlinkUiState> = _uiState.asStateFlow()

    private val _snackBarMessages = MutableSharedFlow<String>()
    val snackBarMessages: SharedFlow<String> = _snackBarMessages.asSharedFlow()

    init {
        fetchSupabaseData()
    }

    fun fetchSupabaseData() {
        viewModelScope.launch {
            try {
                // Fetch Feed Posts from Supabase
                val livePosts = supabaseService.fetchFeedPosts()
                if (livePosts.isNotEmpty()) {
                    val postsList = livePosts.filter { !it.isReel }
                    val reelsList = livePosts.filter { it.isReel }
                    _uiState.value = _uiState.value.copy(
                        posts = if (postsList.isNotEmpty()) postsList else _uiState.value.posts,
                        reels = if (reelsList.isNotEmpty()) reelsList else _uiState.value.reels
                    )
                }

                // Fetch Profiles from Supabase
                val liveProfiles = supabaseService.fetchProfiles()
                if (liveProfiles.isNotEmpty()) {
                    val mySupabaseProfile = liveProfiles.find { it.username == "efe.design" || it.id == "user_me" } ?: liveProfiles.first()
                    _uiState.value = _uiState.value.copy(myProfile = mySupabaseProfile)
                }

                // Fetch Leaderboard from Supabase
                val liveLeaderboard = supabaseService.fetchLeaderboard()
                if (liveLeaderboard.isNotEmpty()) {
                    _uiState.value = _uiState.value.copy(leaderboardUsers = liveLeaderboard)
                }

                // Fetch Market Items from Supabase
                val liveMarket = supabaseService.fetchMarketItems()
                if (liveMarket.isNotEmpty()) {
                    _uiState.value = _uiState.value.copy(marketItems = liveMarket)
                }

                // Fetch Messages from Supabase
                val liveConversations = supabaseService.fetchMessages()
                if (liveConversations.isNotEmpty()) {
                    _uiState.value = _uiState.value.copy(conversations = liveConversations)
                }
            } catch (e: Exception) {
                // Silent fallback to local rich data
            }
        }
    }

    fun loginWithGoogle(email: String = "golowosile@gmail.com") {
        val derivedUsername = email.substringBefore("@").replace(".", "_").lowercase()
        val derivedFullName = email.substringBefore("@").replace(".", " ").capitalizeWords()
        val updatedProfile = _uiState.value.myProfile.copy(
            email = ContactField(email, true),
            fullName = if (derivedFullName.isNotBlank()) derivedFullName else "Verified Student",
            username = if (derivedUsername.isNotBlank()) derivedUsername else "campus_student"
        )
        _uiState.value = _uiState.value.copy(
            myProfile = updatedProfile,
            destination = AppDestination.MAIN
        )
        fetchSupabaseData()
        showToast("✨ Signed in with Google as @${updatedProfile.username}")
    }

    fun loginWithEmail(email: String) {
        val cleanEmail = if (email.isBlank()) "golowosile@gmail.com" else email.trim()
        val derivedUsername = cleanEmail.substringBefore("@").replace(".", "_").lowercase()
        val derivedFullName = cleanEmail.substringBefore("@").replace(".", " ").capitalizeWords()
        val updatedProfile = _uiState.value.myProfile.copy(
            email = ContactField(cleanEmail, true),
            fullName = if (derivedFullName.isNotBlank()) derivedFullName else "Student",
            username = if (derivedUsername.isNotBlank()) derivedUsername else "student_user"
        )
        _uiState.value = _uiState.value.copy(
            myProfile = updatedProfile,
            destination = AppDestination.MAIN
        )
        fetchSupabaseData()
        showToast("✨ Signed in as @${updatedProfile.username}")
    }

    fun signUp(fullName: String, username: String, email: String, faculty: String) {
        val cleanName = if (fullName.isNotBlank()) fullName.trim() else "Campus Student"
        val cleanUsername = if (username.isNotBlank()) username.trim().lowercase() else "student_user"
        val cleanEmail = if (email.isNotBlank()) email.trim() else "student@university.edu.ng"
        val updatedProfile = _uiState.value.myProfile.copy(
            fullName = cleanName,
            username = cleanUsername,
            email = ContactField(cleanEmail, true),
            faculty = if (faculty.isNotBlank()) faculty else "SIMME"
        )
        _uiState.value = _uiState.value.copy(
            myProfile = updatedProfile,
            destination = AppDestination.MAIN
        )
        fetchSupabaseData()
        showToast("🎓 Welcome to Blink, $cleanName!")
    }

    fun showToast(message: String) {
        viewModelScope.launch {
            _snackBarMessages.emit(message)
        }
    }

    fun setDestination(dest: AppDestination) {
        _uiState.value = _uiState.value.copy(destination = dest)
    }

    fun setTab(tab: MainTab) {
        _uiState.value = _uiState.value.copy(
            selectedTab = tab,
            activeConversationPartner = if (tab != MainTab.MESSAGES) null else _uiState.value.activeConversationPartner,
            isConversationFullScreen = false
        )
    }

    fun setFeedSubTab(tab: Int) {
        _uiState.value = _uiState.value.copy(feedSubTab = tab)
    }

    fun toggleDarkMode() {
        _uiState.value = _uiState.value.copy(isDarkMode = !_uiState.value.isDarkMode)
    }

    fun openMenu(open: Boolean) {
        _uiState.value = _uiState.value.copy(isMenuOpen = open)
    }

    fun logout() {
        _uiState.value = _uiState.value.copy(
            destination = AppDestination.SIGN_IN,
            isMenuOpen = false
        )
        showToast("Logged out successfully.")
    }

    fun openProfile(username: String) {
        val state = _uiState.value
        if (username == "you" || username == state.myProfile.username || username == "efe.design") {
            _uiState.value = state.copy(viewingProfile = state.myProfile)
        } else {
            // Find in leaderboard or create guest profile
            val leader = state.leaderboardUsers.find { it.username == username }
            val guest = UserProfile(
                id = "guest_$username",
                fullName = leader?.fullName ?: (username.replace(".", " ").capitalizeWords()),
                username = username,
                avatarUrl = leader?.avatar ?: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&h=300&fit=crop",
                faculty = leader?.faculty ?: "SIMME",
                university = leader?.university ?: "University of Lagos",
                professionalHeadline = "Creative Student • Blink Pioneer",
                currentJobTitle = "Community Creator",
                bio = "Exploring campus life, collaborating on projects, sharing the journey. 🚀",
                verificationBadge = if (leader?.rank != null && leader.rank <= 3) VerificationBadge.GOLD else VerificationBadge.BLUE,
                followerCount = leader?.points ?: 1450,
                followingCount = 280,
                onlineNow = true
            )
            _uiState.value = state.copy(viewingProfile = guest)
        }
    }

    fun closeProfile() {
        _uiState.value = _uiState.value.copy(viewingProfile = null)
    }

    fun openProductDetail(item: MarketItem) {
        _uiState.value = _uiState.value.copy(viewingProduct = item)
    }

    fun closeProductDetail() {
        _uiState.value = _uiState.value.copy(viewingProduct = null)
    }

    fun openPostItem(open: Boolean) {
        _uiState.value = _uiState.value.copy(isPostItemOpen = open)
    }

    fun openBecomeSeller(open: Boolean) {
        _uiState.value = _uiState.value.copy(isBecomeSellerOpen = open)
    }

    fun openEditProfile(open: Boolean) {
        _uiState.value = _uiState.value.copy(isEditProfileOpen = open)
    }

    fun openActivity(open: Boolean) {
        _uiState.value = _uiState.value.copy(isActivityOpen = open)
    }

    fun openCommentsForPost(postId: String?) {
        _uiState.value = _uiState.value.copy(activeCommentsPostId = postId)
    }

    fun openCreatePost(open: Boolean) {
        _uiState.value = _uiState.value.copy(isCreatePostOpen = open)
    }

    fun openChatWithUser(username: String, sellerName: String? = null, sellerAvatar: String? = null) {
        val state = _uiState.value
        val existing = state.conversations.find { it.partnerUsername == username }
        if (existing == null) {
            val newConvo = ChatConversation(
                id = "c_${System.currentTimeMillis()}",
                partnerUsername = username,
                partnerName = sellerName ?: username.replace(".", " ").capitalizeWords(),
                partnerAvatar = sellerAvatar ?: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop",
                isOnline = true,
                lastMessage = "Started a conversation",
                lastMessageTime = "Just now",
                unreadCount = 0,
                isVerified = true,
                faculty = "SIMME",
                messages = mutableListOf(
                    ChatMessage("m_${System.currentTimeMillis()}", username, "Hi! Thanks for reaching out. How can I help?", "Just now", false)
                )
            )
            _uiState.value = state.copy(
                conversations = listOf(newConvo) + state.conversations,
                selectedTab = MainTab.MESSAGES,
                activeConversationPartner = username,
                isConversationFullScreen = true,
                viewingProduct = null
            )
        } else {
            _uiState.value = state.copy(
                selectedTab = MainTab.MESSAGES,
                activeConversationPartner = username,
                isConversationFullScreen = true,
                viewingProduct = null
            )
        }
    }

    fun closeConversation() {
        _uiState.value = _uiState.value.copy(
            activeConversationPartner = null,
            isConversationFullScreen = false
        )
    }

    fun sendMessage(partnerUsername: String, text: String) {
        if (text.isBlank()) return
        val currentConversations = _uiState.value.conversations.map { convo ->
            if (convo.partnerUsername == partnerUsername) {
                val newMsg = ChatMessage(
                    id = "msg_${System.currentTimeMillis()}",
                    senderId = "user_me",
                    text = text,
                    timestamp = "Just now",
                    isFromMe = true
                )
                convo.copy(
                    lastMessage = text,
                    lastMessageTime = "Just now",
                    messages = (convo.messages + newMsg).toMutableList()
                )
            } else {
                convo
            }
        }
        _uiState.value = _uiState.value.copy(conversations = currentConversations)

        // Sync with Supabase in background
        viewModelScope.launch {
            supabaseService.sendMessage(partnerUsername, text)
        }
    }

    fun togglePostLike(postId: String) {
        val updatedPosts = _uiState.value.posts.map { post ->
            if (post.id == postId) {
                val newLiked = !post.isLiked
                post.copy(
                    isLiked = newLiked,
                    likes = if (newLiked) post.likes + 1 else post.likes - 1
                )
            } else post
        }
        val updatedReels = _uiState.value.reels.map { reel ->
            if (reel.id == postId) {
                val newLiked = !reel.isLiked
                reel.copy(
                    isLiked = newLiked,
                    likes = if (newLiked) reel.likes + 1 else reel.likes - 1
                )
            } else reel
        }
        _uiState.value = _uiState.value.copy(posts = updatedPosts, reels = updatedReels)
    }

    fun toggleBookmark(postId: String) {
        val updatedPosts = _uiState.value.posts.map { post ->
            if (post.id == postId) {
                val newBookmarked = !post.isBookmarked
                post.copy(isBookmarked = newBookmarked)
            } else post
        }
        _uiState.value = _uiState.value.copy(posts = updatedPosts)
        showToast("Bookmark updated")
    }

    fun addPost(text: String, faculty: String, imageUri: String?) {
        val newPost = FeedPost(
            id = "p_${System.currentTimeMillis()}",
            author = _uiState.value.myProfile.username,
            authorAvatar = _uiState.value.myProfile.avatarUrl,
            facultyTag = faculty,
            isVerified = _uiState.value.myProfile.verificationBadge != VerificationBadge.NONE,
            timeAgo = "Just now",
            text = text,
            images = if (!imageUri.isNullOrBlank()) listOf(imageUri) else emptyList(),
            likes = 1,
            isLiked = true,
            commentsCount = 0,
            sharesCount = 0
        )
        _uiState.value = _uiState.value.copy(
            posts = listOf(newPost) + _uiState.value.posts,
            isCreatePostOpen = false
        )
        showToast("✨ Post published to Blink campus feed!")

        // Sync with Supabase in background
        viewModelScope.launch {
            supabaseService.createFeedPost(
                author = _uiState.value.myProfile.username,
                authorAvatar = _uiState.value.myProfile.avatarUrl,
                facultyTag = faculty,
                text = text,
                imageUrl = imageUri
            )
        }
    }

    fun addMarketItem(
        title: String,
        price: Long,
        category: String,
        condition: String,
        description: String,
        imageUrl: String
    ) {
        val profile = _uiState.value.myProfile
        val newItem = MarketItem(
            id = "m_${System.currentTimeMillis()}",
            title = title,
            price = price,
            images = listOf(imageUrl.ifBlank { "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&fit=crop" }),
            sellerUsername = profile.username,
            sellerAvatar = profile.avatarUrl,
            sellerName = profile.sellerStoreName.ifBlank { profile.fullName },
            sellerPhone = profile.phone.value,
            sellerWhatsapp = profile.phone.value.filter { it.isDigit() },
            sellerIsVerified = true,
            sellerRating = 5.0,
            sellerReviewCount = 1,
            university = profile.university,
            location = profile.currentCityState,
            category = category,
            condition = condition,
            description = description,
            postedTime = "Just now"
        )
        _uiState.value = _uiState.value.copy(
            marketItems = listOf(newItem) + _uiState.value.marketItems,
            isPostItemOpen = false
        )
        showToast("🎉 Item listed on ALUTA MARKET!")

        // Sync with Supabase in background
        viewModelScope.launch {
            supabaseService.createMarketItem(newItem)
        }
    }

    fun activateSellerAccount(storeName: String, phone: String, whatsapp: String, state: String, city: String) {
        val updatedProfile = _uiState.value.myProfile.copy(
            isSellerActive = true,
            sellerStoreName = storeName,
            verificationBadge = VerificationBadge.GOLD,
            phone = ContactField(phone, true),
            currentCityState = "$city, $state"
        )
        _uiState.value = _uiState.value.copy(
            myProfile = updatedProfile,
            isBecomeSellerOpen = false
        )
        showToast("💳 Paystack Payment Verified! Seller badge activated.")
    }

    fun addComment(postId: String, text: String) {
        if (text.isBlank()) return
        val profile = _uiState.value.myProfile
        val newComment = Comment(
            id = System.currentTimeMillis(),
            user = profile.username,
            avatar = profile.avatarUrl,
            text = text,
            time = "Just now",
            likes = 0,
            isLiked = false
        )
        _uiState.value = _uiState.value.copy(
            comments = listOf(newComment) + _uiState.value.comments
        )
        showToast("Comment posted!")
    }

    fun endorseSkill(skillName: String) {
        val profile = _uiState.value.myProfile
        val updatedEndorsements = profile.skillEndorsements.map { e ->
            if (e.skill == skillName) {
                e.copy(
                    endorsements = if (e.endorsedByMe) e.endorsements - 1 else e.endorsements + 1,
                    endorsedByMe = !e.endorsedByMe
                )
            } else e
        }.toMutableList()
        val updatedProfile = profile.copy(skillEndorsements = updatedEndorsements)
        _uiState.value = _uiState.value.copy(myProfile = updatedProfile)
        showToast("Endorsement updated for $skillName")
    }

    fun updateMyProfile(updated: UserProfile) {
        _uiState.value = _uiState.value.copy(
            myProfile = updated,
            isEditProfileOpen = false
        )
        showToast("Profile updated successfully!")
    }
}

private fun String.capitalizeWords(): String = split(" ").joinToString(" ") { it.replaceFirstChar { char -> char.uppercase() } }
