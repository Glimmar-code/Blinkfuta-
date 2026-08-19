package com.example.data.supabase

import android.util.Log
import com.example.data.models.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.TimeUnit

class SupabaseService {

    private val client = OkHttpClient.Builder()
        .connectTimeout(15, TimeUnit.SECONDS)
        .readTimeout(15, TimeUnit.SECONDS)
        .writeTimeout(15, TimeUnit.SECONDS)
        .build()

    private val jsonMediaType = "application/json; charset=utf-8".toMediaType()

    private val baseUrl = SupabaseConfig.url.trimEnd('/')
    private val anonKey = SupabaseConfig.anonKey

    private fun newRequestBuilder(endpoint: String): Request.Builder {
        val fullUrl = if (endpoint.startsWith("http")) endpoint else "$baseUrl$endpoint"
        return Request.Builder()
            .url(fullUrl)
            .addHeader("apikey", anonKey)
            .addHeader("Authorization", "Bearer $anonKey")
            .addHeader("Accept", "application/json")
    }

    /**
     * Authenticate against Supabase Auth endpoint or verify registered profiles
     */
    suspend fun authenticateUser(emailOrUsername: String, password: String): Result<UserProfile> = withContext(Dispatchers.IO) {
        try {
            val cleanInput = emailOrUsername.trim().lowercase()

            // 1. Try Supabase Auth API
            val authJson = JSONObject().apply {
                put("email", if (cleanInput.contains("@")) cleanInput else "$cleanInput@student.university.edu.ng")
                put("password", password)
            }
            val authBody = authJson.toString().toRequestBody(jsonMediaType)
            val authRequest = newRequestBuilder("/auth/v1/token?grant_type=password")
                .post(authBody)
                .build()

            client.newCall(authRequest).execute().use { authResp ->
                if (authResp.isSuccessful) {
                    val respBody = authResp.body?.string().orEmpty()
                    if (respBody.isNotBlank()) {
                        val authObj = JSONObject(respBody)
                        val userObj = authObj.optJSONObject("user")
                        val meta = userObj?.optJSONObject("user_metadata")
                        val profile = UserProfile(
                            id = userObj?.optString("id", "user_me") ?: "user_me",
                            email = ContactField(userObj?.optString("email", cleanInput) ?: cleanInput, true),
                            fullName = meta?.optString("full_name", meta?.optString("name", "Student")) ?: "Student",
                            username = meta?.optString("username", cleanInput.substringBefore("@")) ?: cleanInput.substringBefore("@"),
                            faculty = meta?.optString("faculty", "SIMME") ?: "SIMME"
                        )
                        return@withContext Result.success(profile)
                    }
                }
            }

            // User unavailable on Supabase or incorrect password
            return@withContext Result.failure(Exception("User unavailable or incorrect password. Please sign up or check your credentials."))
        } catch (e: Exception) {
            Log.e("SupabaseService", "Auth error: ${e.message}")
            return@withContext Result.failure(Exception("User unavailable or incorrect password."))
        }
    }

    /**
     * Send password recovery email via Supabase
     */
    suspend fun recoverPassword(email: String): Boolean = withContext(Dispatchers.IO) {
        try {
            val json = JSONObject().apply {
                put("email", email.trim().lowercase())
            }
            val body = json.toString().toRequestBody(jsonMediaType)
            val request = newRequestBuilder("/auth/v1/recover")
                .post(body)
                .build()

            client.newCall(request).execute().use { response ->
                response.isSuccessful || response.code == 200 || response.code == 429
            }
        } catch (e: Exception) {
            Log.e("SupabaseService", "Recover password error: ${e.message}")
            true
        }
    }

    suspend fun fetchFeedPosts(): List<FeedPost> = withContext(Dispatchers.IO) {
        val endpoints = listOf(
            "/rest/v1/feed_posts?select=*&order=created_at.desc&limit=50",
            "/rest/v1/posts?select=*&order=created_at.desc&limit=50",
            "/rest/v1/feeds?select=*&order=created_at.desc&limit=50"
        )

        for (endpoint in endpoints) {
            try {
                val request = newRequestBuilder(endpoint).get().build()
                client.newCall(request).execute().use { response ->
                    if (response.isSuccessful) {
                        val body = response.body?.string().orEmpty()
                        if (body.isNotBlank() && body != "[]" && body != "null") {
                            val jsonArray = JSONArray(body)
                            val posts = mutableListOf<FeedPost>()
                            for (i in 0 until jsonArray.length()) {
                                val obj = jsonArray.optJSONObject(i) ?: continue
                                parseFeedPost(obj)?.let { posts.add(it) }
                            }
                            if (posts.isNotEmpty()) return@withContext posts
                        }
                    }
                }
            } catch (e: Exception) {
                Log.e("SupabaseService", "fetchFeedPosts failed on $endpoint: ${e.message}")
            }
        }
        emptyList()
    }

    suspend fun createFeedPost(
        author: String,
        authorAvatar: String,
        facultyTag: String,
        text: String,
        imageUrl: String?
    ): Boolean = withContext(Dispatchers.IO) {
        try {
            val json = JSONObject().apply {
                put("type", if (!imageUrl.isNullOrBlank()) "photo" else "text")
                put("faculty", facultyTag.ifBlank { "SIMME" })
                put("text", text)
                if (!imageUrl.isNullOrBlank()) {
                    put("image_url", imageUrl)
                }
                put("created_at", java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", java.util.Locale.US).format(java.util.Date()))
                put("like_count", 0)
                put("comment_count", 0)
                put("share_count", 0)
                put("username", author)
                put("avatar_url", authorAvatar)
            }

            val body = json.toString().toRequestBody(jsonMediaType)
            val request = newRequestBuilder("/rest/v1/feed_posts")
                .addHeader("Prefer", "return=representation")
                .post(body)
                .build()

            client.newCall(request).execute().use { response ->
                response.isSuccessful
            }
        } catch (e: Exception) {
            Log.e("SupabaseService", "Error creating feed post: ${e.message}")
            false
        }
    }

    suspend fun fetchProfiles(): List<UserProfile> = withContext(Dispatchers.IO) {
        val endpoints = listOf(
            "/rest/v1/profiles?select=*&limit=50",
            "/rest/v1/users?select=*&limit=50",
            "/rest/v1/students?select=*&limit=50"
        )
        for (endpoint in endpoints) {
            try {
                val request = newRequestBuilder(endpoint).get().build()
                client.newCall(request).execute().use { response ->
                    if (response.isSuccessful) {
                        val body = response.body?.string().orEmpty()
                        if (body.isNotBlank() && body != "[]" && body != "null") {
                            val jsonArray = JSONArray(body)
                            val list = mutableListOf<UserProfile>()
                            for (i in 0 until jsonArray.length()) {
                                val obj = jsonArray.optJSONObject(i) ?: continue
                                parseUserProfile(obj)?.let { list.add(it) }
                            }
                            if (list.isNotEmpty()) return@withContext list
                        }
                    }
                }
            } catch (e: Exception) {
                Log.e("SupabaseService", "fetchProfiles failed on $endpoint: ${e.message}")
            }
        }
        emptyList()
    }

    suspend fun fetchLeaderboard(): List<LeaderboardUser> = withContext(Dispatchers.IO) {
        val endpoints = listOf(
            "/rest/v1/leaderboard?select=*&order=points.desc&limit=50",
            "/rest/v1/rankings?select=*&order=points.desc&limit=50",
            "/rest/v1/ranks?select=*&order=points.desc&limit=50"
        )
        for (endpoint in endpoints) {
            try {
                val request = newRequestBuilder(endpoint).get().build()
                client.newCall(request).execute().use { response ->
                    if (response.isSuccessful) {
                        val body = response.body?.string().orEmpty()
                        if (body.isNotBlank() && body != "[]" && body != "null") {
                            val jsonArray = JSONArray(body)
                            val list = mutableListOf<LeaderboardUser>()
                            for (i in 0 until jsonArray.length()) {
                                val obj = jsonArray.optJSONObject(i) ?: continue
                                parseLeaderboardUser(obj, i + 1)?.let { list.add(it) }
                            }
                            if (list.isNotEmpty()) return@withContext list
                        }
                    }
                }
            } catch (e: Exception) {
                Log.e("SupabaseService", "fetchLeaderboard failed on $endpoint: ${e.message}")
            }
        }
        emptyList()
    }

    suspend fun fetchMarketItems(): List<MarketItem> = withContext(Dispatchers.IO) {
        val endpoints = listOf(
            "/rest/v1/market_items?select=*&order=created_at.desc&limit=50",
            "/rest/v1/products?select=*&order=created_at.desc&limit=50",
            "/rest/v1/market?select=*&order=created_at.desc&limit=50"
        )
        for (endpoint in endpoints) {
            try {
                val request = newRequestBuilder(endpoint).get().build()
                client.newCall(request).execute().use { response ->
                    if (response.isSuccessful) {
                        val body = response.body?.string().orEmpty()
                        if (body.isNotBlank() && body != "[]" && body != "null") {
                            val jsonArray = JSONArray(body)
                            val list = mutableListOf<MarketItem>()
                            for (i in 0 until jsonArray.length()) {
                                val obj = jsonArray.optJSONObject(i) ?: continue
                                parseMarketItem(obj)?.let { list.add(it) }
                            }
                            if (list.isNotEmpty()) return@withContext list
                        }
                    }
                }
            } catch (e: Exception) {
                Log.e("SupabaseService", "fetchMarketItems failed on $endpoint: ${e.message}")
            }
        }
        emptyList()
    }

    suspend fun createMarketItem(item: MarketItem): Boolean = withContext(Dispatchers.IO) {
        try {
            val json = JSONObject().apply {
                put("title", item.title)
                put("price", item.price)
                put("category", item.category)
                put("condition", item.condition)
                put("description", item.description)
                put("image_url", item.images.firstOrNull() ?: "")
                put("seller_username", item.sellerUsername)
                put("seller_name", item.sellerName)
                put("seller_avatar", item.sellerAvatar)
                put("seller_phone", item.sellerPhone)
                put("seller_whatsapp", item.sellerWhatsapp)
                put("university", item.university)
                put("location", item.location)
            }
            val body = json.toString().toRequestBody(jsonMediaType)
            val request = newRequestBuilder("/rest/v1/market_items")
                .addHeader("Prefer", "return=representation")
                .post(body)
                .build()

            client.newCall(request).execute().use { response ->
                response.isSuccessful
            }
        } catch (e: Exception) {
            Log.e("SupabaseService", "Error creating market item: ${e.message}")
            false
        }
    }

    suspend fun fetchMessages(): List<ChatConversation> = withContext(Dispatchers.IO) {
        val endpoints = listOf(
            "/rest/v1/messages?select=*&order=created_at.desc&limit=100",
            "/rest/v1/chats?select=*&order=created_at.desc&limit=100"
        )
        for (endpoint in endpoints) {
            try {
                val request = newRequestBuilder(endpoint).get().build()
                client.newCall(request).execute().use { response ->
                    if (response.isSuccessful) {
                        val body = response.body?.string().orEmpty()
                        if (body.isNotBlank() && body != "[]" && body != "null") {
                            val jsonArray = JSONArray(body)
                            val convosMap = mutableMapOf<String, MutableList<ChatMessage>>()
                            for (i in 0 until jsonArray.length()) {
                                val obj = jsonArray.optJSONObject(i) ?: continue
                                val sender = obj.optString("sender_username", obj.optString("sender_id", "user"))
                                val receiver = obj.optString("receiver_username", "you")
                                val partner = if (sender == "efe.design" || sender == "user_me" || sender == "golowosile") receiver else sender
                                val text = obj.optString("text", obj.optString("content", obj.optString("message", "")))
                                val time = obj.optString("created_at", "Just now")
                                val isMe = sender == "efe.design" || sender == "user_me" || sender == "golowosile"
                                val msg = ChatMessage(
                                    id = obj.optString("id", System.currentTimeMillis().toString()),
                                    senderId = sender,
                                    text = text,
                                    timestamp = formatTimeAgo(time),
                                    isFromMe = isMe
                                )
                                convosMap.getOrPut(partner) { mutableListOf() }.add(msg)
                            }

                            val conversations = convosMap.map { (partner, msgs) ->
                                ChatConversation(
                                    id = "conv_$partner",
                                    partnerUsername = partner,
                                    partnerName = partner.replace(".", " ").replace("_", " ").capitalizeWords(),
                                    partnerAvatar = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop",
                                    isOnline = true,
                                    lastMessage = msgs.firstOrNull()?.text ?: "",
                                    lastMessageTime = msgs.firstOrNull()?.timestamp ?: "Just now",
                                    unreadCount = 0,
                                    isVerified = true,
                                    messages = msgs
                                )
                            }
                            if (conversations.isNotEmpty()) return@withContext conversations
                        }
                    }
                }
            } catch (e: Exception) {
                Log.e("SupabaseService", "fetchMessages failed on $endpoint: ${e.message}")
            }
        }
        emptyList()
    }

    suspend fun sendMessage(receiverUsername: String, text: String): Boolean = withContext(Dispatchers.IO) {
        try {
            val json = JSONObject().apply {
                put("sender_username", "golowosile")
                put("receiver_username", receiverUsername)
                put("text", text)
                put("created_at", java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", java.util.Locale.US).format(java.util.Date()))
            }
            val body = json.toString().toRequestBody(jsonMediaType)
            val request = newRequestBuilder("/rest/v1/messages")
                .addHeader("Prefer", "return=representation")
                .post(body)
                .build()

            client.newCall(request).execute().use { response ->
                response.isSuccessful
            }
        } catch (e: Exception) {
            Log.e("SupabaseService", "Error sending message: ${e.message}")
            false
        }
    }

    private fun parseFeedPost(obj: JSONObject): FeedPost? {
        val id = obj.optString("id", System.currentTimeMillis().toString())
        val text = obj.optString("text", obj.optString("caption", obj.optString("content", obj.optString("body", ""))))
        val faculty = obj.optString("faculty", obj.optString("faculty_tag", "SIMME")).ifBlank { "SIMME" }
        val imageUrl = obj.optString("image_url", obj.optString("imageUrl", obj.optString("media_url", "")))
        val type = obj.optString("type", "").lowercase()
        val isReel = type == "reel" || type == "video"
        val author = obj.optString("username", obj.optString("author", obj.optString("author_name", "campus_student"))).ifBlank { "student" }
        val avatar = obj.optString("avatar_url", obj.optString("author_avatar", "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&h=300&fit=crop")).ifBlank {
            "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&h=300&fit=crop"
        }
        val likes = obj.optInt("like_count", obj.optInt("likes", 14))
        val comments = obj.optInt("comment_count", obj.optInt("comments", 2))
        val shares = obj.optInt("share_count", obj.optInt("shares", 1))
        val createdAt = obj.optString("created_at", "")

        return FeedPost(
            id = id,
            author = author,
            authorAvatar = avatar,
            facultyTag = faculty,
            isVerified = true,
            timeAgo = formatTimeAgo(createdAt),
            text = text,
            images = if (imageUrl.isNotBlank()) listOf(imageUrl) else emptyList(),
            likes = likes,
            isLiked = false,
            commentsCount = comments,
            sharesCount = shares,
            isReel = isReel
        )
    }

    suspend fun updateProfile(profile: UserProfile): Boolean = withContext(Dispatchers.IO) {
        try {
            val json = JSONObject().apply {
                put("full_name", profile.fullName)
                put("username", profile.username)
                put("avatar_url", profile.avatarUrl)
                put("cover_url", profile.coverPhotoUrl)
                put("bio", profile.bio)
                put("faculty", profile.faculty)
                put("university", profile.university)
            }
            val request = newRequestBuilder("/rest/v1/profiles?username=eq.${profile.username}")
                .patch(json.toString().toRequestBody("application/json".toMediaType()))
                .build()
            client.newCall(request).execute().use { response ->
                return@withContext response.isSuccessful
            }
        } catch (e: Exception) {
            Log.e("SupabaseService", "updateProfile error: ${e.message}")
            false
        }
    }

    private fun parseUserProfile(obj: JSONObject): UserProfile? {
        val id = obj.optString("id", "user_me")
        val fullName = obj.optString("full_name", obj.optString("name", obj.optString("display_name", "Gbolahan Olowosile"))).ifBlank { "Gbolahan Olowosile" }
        val username = obj.optString("username", obj.optString("user_name", "golowosile")).ifBlank { "golowosile" }
        val avatarUrl = obj.optString("avatar_url", obj.optString("avatar", "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&h=300&fit=crop")).ifBlank {
            "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&h=300&fit=crop"
        }
        val coverPhotoUrl = obj.optString("cover_photo_url", "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1000&h=400&fit=crop").ifBlank {
            "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1000&h=400&fit=crop"
        }
        val faculty = obj.optString("faculty", "SIMME").ifBlank { "SIMME" }
        val university = obj.optString("university", "University of Lagos (UNILAG)").ifBlank { "University of Lagos" }
        val department = obj.optString("department", "Systems Engineering").ifBlank { "Systems Engineering" }
        val academicLevel = obj.optString("academic_level", "400 Level").ifBlank { "400 Level" }
        val bio = obj.optString("bio", "Connecting campus entrepreneurs, sharing reels, building the future on Blink 🚀").ifBlank {
            "Connecting campus entrepreneurs, sharing reels, building the future on Blink 🚀"
        }
        val headline = obj.optString("professional_headline", "Student Innovator • Product Lead").ifBlank {
            "Student Innovator • Product Lead"
        }

        return UserProfile(
            id = id,
            fullName = fullName,
            username = username,
            avatarUrl = avatarUrl,
            coverPhotoUrl = coverPhotoUrl,
            faculty = faculty,
            university = university,
            department = department,
            academicLevel = academicLevel,
            bio = bio,
            professionalHeadline = headline,
            followerCount = obj.optInt("follower_count", 2450),
            followingCount = obj.optInt("following_count", 380),
            profileViewsThisWeek = obj.optInt("profile_views", 312),
            onlineNow = true
        )
    }

    private fun parseLeaderboardUser(obj: JSONObject, defaultRank: Int): LeaderboardUser? {
        val username = obj.optString("username", "scholar_$defaultRank").ifBlank { "scholar_$defaultRank" }
        val fullName = obj.optString("full_name", obj.optString("name", username.replace(".", " ").capitalizeWords())).ifBlank { "Campus Scholar" }
        val avatar = obj.optString("avatar_url", obj.optString("avatar", "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop")).ifBlank {
            "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop"
        }
        val points = obj.optInt("points", obj.optInt("score", 1200 - defaultRank * 60))

        return LeaderboardUser(
            rank = obj.optInt("rank", defaultRank),
            username = username,
            fullName = fullName,
            avatar = avatar,
            points = points,
            faculty = obj.optString("faculty", "SIMME").ifBlank { "SIMME" },
            university = obj.optString("university", "University of Lagos"),
            level = obj.optString("level", "400 Level"),
            streakDays = obj.optInt("streak_days", 14)
        )
    }

    private fun parseMarketItem(obj: JSONObject): MarketItem? {
        val title = obj.optString("title", obj.optString("name", "Campus Item")).ifBlank { "Campus Item" }
        val price = obj.optLong("price", 15000L)
        val imageUrl = obj.optString("image_url", "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&fit=crop").ifBlank {
            "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&fit=crop"
        }
        val sellerUsername = obj.optString("seller_username", "aluta_merchant").ifBlank { "aluta_merchant" }
        val sellerName = obj.optString("seller_name", "Verified Student Seller").ifBlank { "Verified Student Seller" }

        return MarketItem(
            id = obj.optString("id", System.currentTimeMillis().toString()),
            title = title,
            price = price,
            images = listOf(imageUrl),
            sellerUsername = sellerUsername,
            sellerAvatar = obj.optString("seller_avatar", "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop"),
            sellerName = sellerName,
            sellerPhone = obj.optString("seller_phone", "+234 812 345 6789"),
            sellerWhatsapp = obj.optString("seller_whatsapp", "+2348123456789"),
            sellerIsVerified = true,
            sellerRating = 4.9,
            sellerReviewCount = 28,
            university = obj.optString("university", "University of Lagos"),
            location = obj.optString("location", "Akoka Campus"),
            category = obj.optString("category", "Electronics"),
            condition = obj.optString("condition", "Excellent"),
            description = obj.optString("description", "Quality campus gear for students."),
            postedTime = formatTimeAgo(obj.optString("created_at", ""))
        )
    }

    suspend fun recordPostView(postId: String, viewerUsername: String): Int = withContext(Dispatchers.IO) {
        try {
            val json = JSONObject().apply {
                put("p_post_id", postId)
                put("p_viewer_username", viewerUsername)
            }
            val request = newRequestBuilder("/rest/v1/rpc/record_post_view")
                .post(json.toString().toRequestBody(jsonMediaType))
                .build()
            client.newCall(request).execute().use { response ->
                if (response.isSuccessful) {
                    val body = response.body?.string().orEmpty()
                    return@withContext body.toIntOrNull() ?: 1
                }
            }
        } catch (e: Exception) {
            Log.e("SupabaseService", "recordPostView error: ${e.message}")
        }
        1
    }

    private fun formatTimeAgo(dateStr: String): String {
        if (dateStr.isBlank()) return "Just now"
        return try {
            val sdf = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", java.util.Locale.US)
            val date = sdf.parse(dateStr.substringBefore("."))
            if (date != null) {
                val diff = System.currentTimeMillis() - date.time
                val minutes = diff / (1000 * 60)
                val hours = minutes / 60
                val days = hours / 24
                when {
                    minutes < 1 -> "Just now"
                    minutes < 60 -> "${minutes}m ago"
                    hours < 24 -> "${hours}h ago"
                    else -> "${days}d ago"
                }
            } else "Recent"
        } catch (_: Exception) {
            "Recent"
        }
    }
}

private fun String.capitalizeWords(): String = split(" ").joinToString(" ") { it.replaceFirstChar { char -> char.uppercase() } }
