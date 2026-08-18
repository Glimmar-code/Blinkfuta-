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

    suspend fun fetchFeedPosts(): List<FeedPost> = withContext(Dispatchers.IO) {
        try {
            // First try feed_posts, fallback to posts
            val endpoints = listOf(
                "/rest/v1/feed_posts?select=*&order=created_at.desc&limit=50",
                "/rest/v1/posts?select=*&order=created_at.desc&limit=50"
            )

            for (endpoint in endpoints) {
                val request = newRequestBuilder(endpoint).get().build()
                client.newCall(request).execute().use { response ->
                    if (response.isSuccessful) {
                        val body = response.body?.string() ?: ""
                        if (body.isNotBlank() && body != "[]") {
                            val jsonArray = JSONArray(body)
                            val posts = mutableListOf<FeedPost>()
                            for (i in 0 until jsonArray.length()) {
                                val obj = jsonArray.getJSONObject(i)
                                posts.add(parseFeedPost(obj))
                            }
                            if (posts.isNotEmpty()) return@withContext posts
                        }
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("SupabaseService", "Error fetching feed posts: ${e.message}")
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
                put("faculty", facultyTag)
                put("text", text)
                if (!imageUrl.isNullOrBlank()) {
                    put("image_url", imageUrl)
                }
                put("created_at", java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", java.util.Locale.US).format(java.util.Date()))
                put("like_count", 0)
                put("comment_count", 0)
                put("share_count", 0)
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
        try {
            val request = newRequestBuilder("/rest/v1/profiles?select=*&limit=50").get().build()
            client.newCall(request).execute().use { response ->
                if (response.isSuccessful) {
                    val body = response.body?.string() ?: ""
                    if (body.isNotBlank() && body != "[]") {
                        val jsonArray = JSONArray(body)
                        val list = mutableListOf<UserProfile>()
                        for (i in 0 until jsonArray.length()) {
                            val obj = jsonArray.getJSONObject(i)
                            list.add(parseUserProfile(obj))
                        }
                        if (list.isNotEmpty()) return@withContext list
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("SupabaseService", "Error fetching profiles: ${e.message}")
        }
        emptyList()
    }

    suspend fun fetchLeaderboard(): List<LeaderboardUser> = withContext(Dispatchers.IO) {
        try {
            val endpoints = listOf(
                "/rest/v1/leaderboard?select=*&order=points.desc&limit=50",
                "/rest/v1/rankings?select=*&order=points.desc&limit=50"
            )
            for (endpoint in endpoints) {
                val request = newRequestBuilder(endpoint).get().build()
                client.newCall(request).execute().use { response ->
                    if (response.isSuccessful) {
                        val body = response.body?.string() ?: ""
                        if (body.isNotBlank() && body != "[]") {
                            val jsonArray = JSONArray(body)
                            val list = mutableListOf<LeaderboardUser>()
                            for (i in 0 until jsonArray.length()) {
                                val obj = jsonArray.getJSONObject(i)
                                list.add(parseLeaderboardUser(obj, i + 1))
                            }
                            if (list.isNotEmpty()) return@withContext list
                        }
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("SupabaseService", "Error fetching leaderboard: ${e.message}")
        }
        emptyList()
    }

    suspend fun fetchMarketItems(): List<MarketItem> = withContext(Dispatchers.IO) {
        try {
            val endpoints = listOf(
                "/rest/v1/market_items?select=*&order=created_at.desc&limit=50",
                "/rest/v1/products?select=*&order=created_at.desc&limit=50"
            )
            for (endpoint in endpoints) {
                val request = newRequestBuilder(endpoint).get().build()
                client.newCall(request).execute().use { response ->
                    if (response.isSuccessful) {
                        val body = response.body?.string() ?: ""
                        if (body.isNotBlank() && body != "[]") {
                            val jsonArray = JSONArray(body)
                            val list = mutableListOf<MarketItem>()
                            for (i in 0 until jsonArray.length()) {
                                val obj = jsonArray.getJSONObject(i)
                                list.add(parseMarketItem(obj))
                            }
                            if (list.isNotEmpty()) return@withContext list
                        }
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("SupabaseService", "Error fetching market items: ${e.message}")
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
        try {
            val request = newRequestBuilder("/rest/v1/messages?select=*&order=created_at.desc&limit=100").get().build()
            client.newCall(request).execute().use { response ->
                if (response.isSuccessful) {
                    val body = response.body?.string() ?: ""
                    if (body.isNotBlank() && body != "[]") {
                        val jsonArray = JSONArray(body)
                        // Group messages by partner or conversation
                        val convosMap = mutableMapOf<String, MutableList<ChatMessage>>()
                        for (i in 0 until jsonArray.length()) {
                            val obj = jsonArray.getJSONObject(i)
                            val sender = obj.optString("sender_username", obj.optString("sender_id", "user"))
                            val receiver = obj.optString("receiver_username", "you")
                            val partner = if (sender == "efe.design" || sender == "user_me") receiver else sender
                            val text = obj.optString("text", obj.optString("content", ""))
                            val time = obj.optString("created_at", "Just now")
                            val isMe = sender == "efe.design" || sender == "user_me"
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
                                partnerName = partner.replace(".", " ").capitalizeWords(),
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
            Log.e("SupabaseService", "Error fetching messages: ${e.message}")
        }
        emptyList()
    }

    suspend fun sendMessage(receiverUsername: String, text: String): Boolean = withContext(Dispatchers.IO) {
        try {
            val json = JSONObject().apply {
                put("sender_username", "efe.design")
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

    private fun parseFeedPost(obj: JSONObject): FeedPost {
        val id = obj.optString("id", System.currentTimeMillis().toString())
        val text = obj.optString("text", obj.optString("caption", ""))
        val faculty = obj.optString("faculty", "SIMME")
        val imageUrl = obj.optString("image_url", "")
        val type = obj.optString("type", "")
        val isReel = type == "reel" || type == "video"
        val author = obj.optString("username", obj.optString("author", "campus_creator"))
        val avatar = obj.optString("avatar_url", obj.optString("author_avatar", "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&h=300&fit=crop"))
        val likes = obj.optInt("like_count", obj.optInt("likes", 12))
        val comments = obj.optInt("comment_count", obj.optInt("comments", 3))
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

    private fun parseUserProfile(obj: JSONObject): UserProfile {
        return UserProfile(
            id = obj.optString("id", "user_me"),
            fullName = obj.optString("full_name", obj.optString("name", "Efe Chukwu")),
            username = obj.optString("username", "efe.design"),
            avatarUrl = obj.optString("avatar_url", "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&h=300&fit=crop"),
            coverPhotoUrl = obj.optString("cover_photo_url", "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1000&h=400&fit=crop"),
            faculty = obj.optString("faculty", "Engineering"),
            university = obj.optString("university", "University of Lagos (UNILAG)"),
            department = obj.optString("department", "Systems Engineering"),
            courseOfStudy = obj.optString("course_of_study", "B.Sc. Systems Engineering"),
            academicLevel = obj.optString("academic_level", "400 Level"),
            bio = obj.optString("bio", "Crafting digital experiences, campus entrepreneurship, building for the next billion users 🚀✨"),
            professionalHeadline = obj.optString("professional_headline", "Product Designer • Creative Technologist"),
            followerCount = obj.optInt("follower_count", 2450),
            followingCount = obj.optInt("following_count", 380),
            profileViewsThisWeek = obj.optInt("profile_views", 312),
            onlineNow = true
        )
    }

    private fun parseLeaderboardUser(obj: JSONObject, defaultRank: Int): LeaderboardUser {
        return LeaderboardUser(
            rank = obj.optInt("rank", defaultRank),
            username = obj.optString("username", "user_$defaultRank"),
            fullName = obj.optString("full_name", obj.optString("name", "Campus Scholar")),
            avatar = obj.optString("avatar_url", obj.optString("avatar", "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop")),
            points = obj.optInt("points", obj.optInt("score", 1000 - defaultRank * 50)),
            faculty = obj.optString("faculty", "SIMME"),
            university = obj.optString("university", "University of Lagos"),
            level = obj.optString("level", "400 Level"),
            streakDays = obj.optInt("streak_days", 14)
        )
    }

    private fun parseMarketItem(obj: JSONObject): MarketItem {
        val imageUrl = obj.optString("image_url", "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&fit=crop")
        return MarketItem(
            id = obj.optString("id", System.currentTimeMillis().toString()),
            title = obj.optString("title", "Campus Item"),
            price = obj.optLong("price", 15000L),
            images = listOf(imageUrl),
            sellerUsername = obj.optString("seller_username", "aluta_merchant"),
            sellerAvatar = obj.optString("seller_avatar", "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop"),
            sellerName = obj.optString("seller_name", "Verified Student Seller"),
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
