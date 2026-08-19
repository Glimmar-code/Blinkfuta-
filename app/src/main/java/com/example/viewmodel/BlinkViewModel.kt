package com.example.viewmodel

import android.app.Application
import android.content.Context
import androidx.lifecycle.AndroidViewModel
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
    SPLASH, ONBOARDING, SIGN_IN, SIGN_UP, PROFILE_SETUP, MAIN
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
    val isGetVerifiedOpen: Boolean = false,
    val activeCommentsPostId: String? = null,
    val activePostOptionsPost: FeedPost? = null,
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
    val mutedUsers: Set<String> = emptySet(),
    val feedSubTab: Int = 0, // 0: Posts, 1: Reels
    val isLiveSupabaseConnected: Boolean = true
)

class BlinkViewModel(application: Application) : AndroidViewModel(application) {

    private val prefs = application.getSharedPreferences("blink_user_session", Context.MODE_PRIVATE)

    private val supabaseService = SupabaseService()

    private val _uiState = MutableStateFlow(BlinkUiState())
    val uiState: StateFlow<BlinkUiState> = _uiState.asStateFlow()

    private val _snackBarMessages = MutableSharedFlow<String>()
    val snackBarMessages: SharedFlow<String> = _snackBarMessages.asSharedFlow()

    init {
        val isLoggedIn = prefs.getBoolean("is_logged_in", false)
        if (isLoggedIn) {
            val savedEmail = prefs.getString("email", "golowosile@gmail.com") ?: "golowosile@gmail.com"
            val savedName = prefs.getString("full_name", "Gbolahan Olowosile") ?: "Gbolahan Olowosile"
            val savedUsername = prefs.getString("username", "golowosile") ?: "golowosile"
            val savedFaculty = prefs.getString("faculty", "SIMME") ?: "SIMME"
            val savedUni = prefs.getString("university", "University of Lagos") ?: "University of Lagos"
            val savedAvatar = prefs.getString("avatar_url", "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&h=300&fit=crop") ?: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&h=300&fit=crop"
            val savedCover = prefs.getString("cover_url", "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1000&h=400&fit=crop") ?: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1000&h=400&fit=crop"

            val restoredProfile = UserProfile(
                email = ContactField(savedEmail, true),
                fullName = savedName,
                username = savedUsername,
                faculty = savedFaculty,
                university = savedUni,
                avatarUrl = savedAvatar,
                coverPhotoUrl = savedCover
            )
            _uiState.value = _uiState.value.copy(
                myProfile = restoredProfile,
                destination = AppDestination.MAIN
            )
        }
        fetchSupabaseData()
    }

    private fun saveSession(profile: UserProfile) {
        prefs.edit().apply {
            putBoolean("is_logged_in", true)
            putString("email", profile.email.value)
            putString("full_name", profile.fullName)
            putString("username", profile.username)
            putString("faculty", profile.faculty)
            putString("university", profile.university)
            putString("avatar_url", profile.avatarUrl)
            putString("cover_url", profile.coverPhotoUrl)
            apply()
        }
    }

    fun fetchSupabaseData() {
        viewModelScope.launch {
            try {
                // Fetch Posts from Supabase
                val livePosts = supabaseService.fetchFeedPosts()
                if (livePosts.isNotEmpty()) {
                    _uiState.value = _uiState.value.copy(posts = livePosts)
                }

                // Fetch Market Listings from Supabase
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
                // Silent fallback to rich local state
            }
        }
    }

    fun signInWithCredentials(
        emailOrUsername: String,
        password: String,
        onResult: (success: Boolean, errorMessage: String?) -> Unit
    ) {
        if (emailOrUsername.isBlank() || password.isBlank()) {
            onResult(false, "Please enter both email/username and password.")
            return
        }
        viewModelScope.launch {
            val result = supabaseService.authenticateUser(emailOrUsername, password)
            result.onSuccess { profile ->
                _uiState.value = _uiState.value.copy(
                    myProfile = profile,
                    destination = AppDestination.MAIN
                )
                saveSession(profile)
                fetchSupabaseData()
                showToast("✨ Signed in as @${profile.username}")
                onResult(true, null)
            }.onFailure { error ->
                val msg = error.message ?: "User unavailable or incorrect password."
                showToast(msg)
                onResult(false, msg)
            }
        }
    }

    fun sendPasswordReset(
        email: String,
        onResult: (success: Boolean, message: String) -> Unit
    ) {
        if (email.isBlank() || !email.contains("@")) {
            onResult(false, "Please enter a valid university or Gmail address.")
            return
        }
        viewModelScope.launch {
            val success = supabaseService.recoverPassword(email)
            if (success) {
                val msg = "Password reset instructions sent to $email. Please check your inbox or spam."
                showToast(msg)
                onResult(true, msg)
            } else {
                val msg = "Could not send reset email. Please verify your address."
                showToast(msg)
                onResult(false, msg)
            }
        }
    }

    fun loginWithGoogle(email: String = "golowosile@gmail.com") {
        viewModelScope.launch {
            showToast("🔍 Fetching profile from Supabase...")
            val profile = supabaseService.getOrCreateGoogleProfile(email)
            _uiState.value = _uiState.value.copy(
                myProfile = profile,
                destination = AppDestination.MAIN
            )
            saveSession(profile)
            fetchSupabaseData()
            showToast("✨ Welcome back, @${profile.username}!")
        }
    }

    fun signUp(fullName: String, username: String, email: String, faculty: String) {
        val cleanName = if (fullName.isNotBlank()) fullName.trim() else "Campus Student"
        val cleanUsername = if (username.isNotBlank()) username.trim().lowercase().replace("@", "") else "student_${System.currentTimeMillis() % 10000}"
        val cleanEmail = if (email.isNotBlank()) email.trim() else "$cleanUsername@unilag.edu.ng"

        val newProfile = _uiState.value.myProfile.copy(
            fullName = cleanName,
            username = cleanUsername,
            email = ContactField(cleanEmail, true),
            faculty = faculty
        )
        _uiState.value = _uiState.value.copy(
            myProfile = newProfile,
            destination = AppDestination.PROFILE_SETUP
        )
        // Also save initial session for sign up so user persists if app closes during onboarding
        saveSession(newProfile)
        showToast("Welcome to Blink! Complete your campus profile.")
    }

    fun completeProfileOnboarding(
        university: String,
        academicLevel: String,
        bio: String,
        skills: List<String>,
        phone: String = "",
        whatsapp: String = ""
    ) {
        val updatedSkills = skills.filter { it.isNotBlank() }.map {
            SkillEndorsement(it, 1, true)
        }
        val current = _uiState.value.myProfile
        val completedProfile = current.copy(
            university = university,
            academicLevel = academicLevel,
            bio = bio,
            skillEndorsements = if (updatedSkills.isNotEmpty()) updatedSkills.toMutableList() else current.skillEndorsements,
            phone = ContactField(if (phone.isNotBlank()) phone else current.phone.value, true),
            whatsapp = ContactField(if (whatsapp.isNotBlank()) whatsapp else current.whatsapp.value, true)
        )
        _uiState.value = _uiState.value.copy(
            myProfile = completedProfile,
            destination = AppDestination.MAIN
        )
        saveSession(completedProfile)
        showToast("🎉 Profile setup complete! Welcome to Blink.")
    }

    fun navigateTo(dest: AppDestination) {
        _uiState.value = _uiState.value.copy(destination = dest)
    }

    fun setDestination(dest: AppDestination) {
        navigateTo(dest)
    }

    fun selectTab(tab: MainTab) {
        _uiState.value = _uiState.value.copy(
            selectedTab = tab,
            viewingProfile = null,
            viewingProduct = null,
            isConversationFullScreen = false
        )
    }

    fun setTab(tab: MainTab) {
        selectTab(tab)
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

    fun openPostOptions(post: FeedPost?) {
        _uiState.value = _uiState.value.copy(activePostOptionsPost = post)
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
                    ChatMessage("m_${System.currentTimeMillis()}", username, "Hi! Thanks for reaching out on Blink. How can I help?", "Just now", false)
                )
            )
            _uiState.value = state.copy(
                conversations = listOf(newConvo) + state.conversations,
                selectedTab = MainTab.MESSAGES,
                activeConversationPartner = username,
                isConversationFullScreen = true,
                viewingProfile = null,
                viewingProduct = null
            )
        } else {
            _uiState.value = state.copy(
                selectedTab = MainTab.MESSAGES,
                activeConversationPartner = username,
                isConversationFullScreen = true,
                viewingProfile = null,
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

    fun sendMessage(partnerUsername: String, text: String, isFromMe: Boolean = true) {
        if (text.isBlank()) return
        val currentConversations = _uiState.value.conversations.map { convo ->
            if (convo.partnerUsername == partnerUsername) {
                val newMsg = ChatMessage(
                    id = "msg_${System.currentTimeMillis()}",
                    senderId = if (isFromMe) "user_me" else partnerUsername,
                    text = text,
                    timestamp = "Just now",
                    isFromMe = isFromMe
                )
                convo.copy(
                    lastMessage = text,
                    lastMessageTime = "Just now",
                    unreadCount = if (isFromMe) convo.unreadCount else convo.unreadCount + 1,
                    messages = (convo.messages + newMsg).toMutableList()
                )
            } else {
                convo
            }
        }
        _uiState.value = _uiState.value.copy(conversations = currentConversations)

        if (isFromMe) {
            // Sync with Supabase in background
            viewModelScope.launch {
                supabaseService.sendMessage(partnerUsername, text)
            }
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
        val updatedReels = _uiState.value.reels.map { reel ->
            if (reel.id == postId) {
                val newBookmarked = !reel.isBookmarked
                reel.copy(isBookmarked = newBookmarked)
            } else reel
        }
        _uiState.value = _uiState.value.copy(posts = updatedPosts, reels = updatedReels)
        showToast("Bookmark updated")
    }

    fun sharePost(postId: String) {
        val updatedPosts = _uiState.value.posts.map { post ->
            if (post.id == postId) {
                post.copy(sharesCount = post.sharesCount + 1)
            } else post
        }
        _uiState.value = _uiState.value.copy(posts = updatedPosts)
        showToast("🔗 Post link copied and shared to campus!")
    }

    fun deletePost(postId: String) {
        val filteredPosts = _uiState.value.posts.filterNot { it.id == postId }
        val filteredReels = _uiState.value.reels.filterNot { it.id == postId }
        _uiState.value = _uiState.value.copy(
            posts = filteredPosts,
            reels = filteredReels,
            activePostOptionsPost = null
        )
        showToast("🗑️ Post deleted successfully.")
    }

    fun reportPost(postId: String, reason: String) {
        _uiState.value = _uiState.value.copy(activePostOptionsPost = null)
        showToast("🚨 Report received: \"$reason\". Campus moderation will review within 2 hours.")
    }

    fun muteUser(username: String) {
        val currentMuted = _uiState.value.mutedUsers + username
        val filteredPosts = _uiState.value.posts.filterNot { it.author == username }
        val filteredReels = _uiState.value.reels.filterNot { it.author == username }
        _uiState.value = _uiState.value.copy(
            mutedUsers = currentMuted,
            posts = filteredPosts,
            reels = filteredReels,
            activePostOptionsPost = null
        )
        showToast("🔇 @$username has been muted. Their posts won't appear in your feed.")
    }

    fun addPost(
        text: String,
        faculty: String,
        imageUri: String?,
        videoUri: String? = null,
        tags: List<String> = emptyList(),
        mentions: List<String> = emptyList(),
        poll: PostPoll? = null,
        isReel: Boolean = false
    ) {
        val newPost = FeedPost(
            id = "p_${System.currentTimeMillis()}",
            author = _uiState.value.myProfile.username,
            authorAvatar = _uiState.value.myProfile.avatarUrl,
            facultyTag = faculty,
            isVerified = _uiState.value.myProfile.verificationBadge != VerificationBadge.NONE,
            timeAgo = "Just now",
            text = text,
            images = if (!imageUri.isNullOrBlank()) listOf(imageUri) else emptyList(),
            videoUrl = videoUri,
            tags = tags,
            mentions = mentions,
            poll = poll,
            isReel = isReel,
            likes = 1,
            isLiked = true,
            commentsCount = 0,
            sharesCount = 0,
            viewsCount = 1
        )
        val updatedPosts = listOf(newPost) + _uiState.value.posts
        val updatedReels = if (isReel || !videoUri.isNullOrBlank()) listOf(newPost) + _uiState.value.reels else _uiState.value.reels

        _uiState.value = _uiState.value.copy(
            posts = updatedPosts,
            reels = updatedReels,
            isCreatePostOpen = false
        )
        showToast(if (isReel) "✨ Campus Reel published!" else "✨ Post published to Blink campus feed!")

        // Sync with Supabase in background
        viewModelScope.launch {
            supabaseService.createFeedPost(
                author = _uiState.value.myProfile.username,
                authorAvatar = _uiState.value.myProfile.avatarUrl,
                facultyTag = faculty,
                text = text,
                imageUrl = imageUri,
                videoUrl = videoUri,
                tags = tags,
                mentions = mentions,
                poll = poll,
                isReel = isReel
            )
        }
    }

    fun votePoll(postId: String, optionId: String) {
        val updatedPosts = _uiState.value.posts.map { post ->
            if (post.id == postId && post.poll != null) {
                val currentPoll = post.poll
                val alreadyVotedOption = currentPoll.options.find { it.isVotedByMe }
                if (alreadyVotedOption?.id == optionId) return@map post

                val updatedOptions = currentPoll.options.map { opt ->
                    if (opt.id == optionId) {
                        opt.copy(votes = opt.votes + 1, isVotedByMe = true)
                    } else if (opt.isVotedByMe) {
                        opt.copy(votes = maxOf(0, opt.votes - 1), isVotedByMe = false)
                    } else {
                        opt
                    }
                }
                val newTotalVotes = if (alreadyVotedOption == null) currentPoll.totalVotes + 1 else currentPoll.totalVotes
                val updatedPoll = currentPoll.copy(options = updatedOptions, totalVotes = newTotalVotes, hasVoted = true)
                post.copy(poll = updatedPoll)
            } else {
                post
            }
        }
        _uiState.value = _uiState.value.copy(posts = updatedPosts)
        showToast("🗳️ Vote recorded!")
    }

    fun addComment(postId: String, text: String, replyToUser: String? = null) {
        val newComment = Comment(
            id = System.currentTimeMillis(),
            user = _uiState.value.myProfile.username,
            avatar = _uiState.value.myProfile.avatarUrl,
            text = text,
            time = "Just now",
            likes = 0,
            isLiked = false
        )
        val updatedComments = listOf(newComment) + _uiState.value.comments
        val updatedPosts = _uiState.value.posts.map { post ->
            if (post.id == postId) {
                post.copy(commentsCount = post.commentsCount + 1)
            } else post
        }
        _uiState.value = _uiState.value.copy(
            comments = updatedComments,
            posts = updatedPosts
        )
        showToast("💬 Comment posted!")
    }

    fun toggleCommentLike(commentId: Long) {
        val updatedComments = _uiState.value.comments.map { comment ->
            if (comment.id == commentId) {
                val newLiked = !comment.isLiked
                comment.copy(
                    isLiked = newLiked,
                    likes = if (newLiked) comment.likes + 1 else comment.likes - 1
                )
            } else comment
        }
        _uiState.value = _uiState.value.copy(comments = updatedComments)
    }

    fun handleNotificationClick(activity: ActivityItem) {
        _uiState.value = _uiState.value.copy(isActivityOpen = false)
        if (activity.targetPostId != null) {
            val targetPost = _uiState.value.posts.find { it.id == activity.targetPostId }
            if (targetPost != null) {
                _uiState.value = _uiState.value.copy(
                    selectedTab = MainTab.HOME,
                    feedSubTab = 0
                )
                if (activity.category == NotificationFilter.COMMENTS) {
                    openCommentsForPost(targetPost.id)
                } else {
                    showToast("Viewing post by @${targetPost.author}")
                }
            }
        } else if (activity.targetMarketId != null) {
            val targetMarket = _uiState.value.marketItems.find { it.id == activity.targetMarketId }
            if (targetMarket != null) {
                openProductDetail(targetMarket)
            }
        } else {
            openProfile(activity.user)
        }
    }

    fun addMarketListing(item: MarketItem) {
        _uiState.value = _uiState.value.copy(
            marketItems = listOf(item) + _uiState.value.marketItems,
            isPostItemOpen = false
        )
        showToast("🛍️ Product listed successfully on Aluta Market!")

        viewModelScope.launch {
            supabaseService.createMarketItem(item)
        }
    }

    fun addMarketItem(
        title: String,
        price: Long,
        category: String,
        condition: String,
        description: String,
        imageUrl: String?
    ) {
        val newItem = MarketItem(
            id = "m_${System.currentTimeMillis()}",
            title = title,
            price = price,
            images = if (!imageUrl.isNullOrBlank()) listOf(imageUrl) else listOf("https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&fit=crop"),
            sellerUsername = _uiState.value.myProfile.username,
            sellerAvatar = _uiState.value.myProfile.avatarUrl,
            sellerName = _uiState.value.myProfile.fullName,
            sellerPhone = _uiState.value.myProfile.phone.value,
            sellerWhatsapp = _uiState.value.myProfile.whatsapp.value,
            sellerIsVerified = true,
            university = _uiState.value.myProfile.university,
            location = _uiState.value.myProfile.currentCityState,
            category = category,
            condition = condition,
            description = description,
            postedTime = "Just now"
        )
        addMarketListing(newItem)
    }

    fun activateSellerAccount(
        storeName: String,
        phone: String,
        whatsapp: String,
        state: String,
        city: String
    ) {
        val current = _uiState.value.myProfile
        val updated = current.copy(
            isSellerActive = true,
            phone = ContactField(phone, true),
            whatsapp = ContactField(whatsapp, true),
            currentCityState = "$city, $state"
        )
        _uiState.value = _uiState.value.copy(
            myProfile = updated,
            isBecomeSellerOpen = false
        )
        showToast("🏪 Aluta Market Seller Store Activated: $storeName")
    }

    fun updateProfile(updated: UserProfile) {
        _uiState.value = _uiState.value.copy(
            myProfile = updated,
            isEditProfileOpen = false
        )
        saveSession(updated)

        // Sync to Supabase & update feed posts / author info across app
        viewModelScope.launch {
            supabaseService.updateProfile(updated)
            val currentPosts = _uiState.value.posts.map { post ->
                if (post.author.equals(updated.fullName, ignoreCase = true) || post.author.contains(updated.username, ignoreCase = true)) {
                    post.copy(
                        author = updated.fullName,
                        authorAvatar = updated.avatarUrl
                    )
                } else post
            }
            _uiState.value = _uiState.value.copy(posts = currentPosts)
        }

        showToast("Profile updated & synced successfully!")
    }

    fun updateMyProfile(updated: UserProfile) {
        updateProfile(updated)
    }

    fun endorseSkill(skill: String) {
        val current = _uiState.value.myProfile
        val updated = current.skillEndorsements.map {
            if (it.skill.equals(skill, ignoreCase = true)) {
                val nextEndorsed = !it.endorsedByMe
                it.copy(
                    endorsedByMe = nextEndorsed,
                    endorsements = if (nextEndorsed) it.endorsements + 1 else it.endorsements - 1
                )
            } else it
        }
        _uiState.value = _uiState.value.copy(myProfile = current.copy(skillEndorsements = updated.toMutableList()))
        showToast("Endorsement updated for $skill")
    }

    fun recordPostView(postId: String) {
        viewModelScope.launch {
            val username = _uiState.value.myProfile.username
            val newViews = supabaseService.recordPostView(postId, username)
            val updatedPosts = _uiState.value.posts.map { post ->
                if (post.id == postId) post.copy(viewsCount = maxOf(post.viewsCount, newViews)) else post
            }
            _uiState.value = _uiState.value.copy(posts = updatedPosts)
        }
    }

    fun showToast(msg: String) {
        viewModelScope.launch {
            _snackBarMessages.emit(msg)
        }
    }

    fun openGetVerified(open: Boolean) {
        _uiState.value = _uiState.value.copy(isGetVerifiedOpen = open)
    }

    fun applyVerification(tier: VerificationBadge) {
        val current = _uiState.value.myProfile
        val updated = current.copy(
            verificationBadge = tier,
            isSellerActive = true // Verified members automatically unlocked for selling on Aluta Market
        )
        _uiState.value = _uiState.value.copy(
            myProfile = updated,
            isGetVerifiedOpen = false
        )
        prefs.edit().putString("verification_badge", tier.name).putBoolean("is_seller_active", true).apply()
        showToast("🎉 Congratulations! You have successfully upgraded to ${if (tier == VerificationBadge.GOLD) "Gold VIP" else "Blue Student"} Verification.")
    }

    fun simulateBackgroundNotification(context: android.content.Context) {
        viewModelScope.launch {
            showToast("You'll receive a message notification in 3 seconds. Try putting the app in the background.")
            kotlinx.coroutines.delay(3000)
            
            // Simulate a message from Kemi
            val simulatedSenderId = "kemi_eng"
            val simulatedSenderName = "Kemi Adeleke"
            val simulatedMsg = "Hey! Let's review those files when you're back online."
            
            // Update UI state with new message
            sendMessage(simulatedSenderId, simulatedMsg, isFromMe = false)
            
            // Trigger actual system notification
            com.example.notification.BlinkNotificationHelper.showChatMessageNotification(
                context = context,
                senderUsername = simulatedSenderId,
                senderName = simulatedSenderName,
                messageText = simulatedMsg
            )
        }
    }
}

private fun String.capitalizeWords(): String =
    split(" ").joinToString(" ") { it.replaceFirstChar { char -> char.uppercase() } }
