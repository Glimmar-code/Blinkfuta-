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

    suspend fun getOrCreateGoogleProfile(email: String, displayName: String? = null, avatarUrl: String? = null): UserProfile = withContext(Dispatchers.IO) {
        val cleanEmail = email.trim().lowercase()
        val derivedUsername = cleanEmail.substringBefore("@").replace(".", "_").lowercase()
        val endpoints = listOf(
            "/rest/v1/profiles?email=eq.$cleanEmail&select=*&limit=1",
            "/rest/v1/profiles?username=eq.$derivedUsername&select=*&limit=1",
            "/rest/v1/users?email=eq.$cleanEmail&select=*&limit=1"
        )
        for (endpoint in endpoints) {
            try {
                val req = newRequestBuilder(endpoint).get().build()
                client.newCall(req).execute().use { resp ->
                    if (resp.isSuccessful) {
                        val body = resp.body?.string().orEmpty()
                        if (body.isNotBlank() && body != "[]" && body != "null") {
                            val arr = JSONArray(body)
                            if (arr.length() > 0) {
                                val obj = arr.getJSONObject(0)
                                parseUserProfile(obj)?.let { profile ->
                                    return@withContext profile.copy(
                                        email = ContactField(cleanEmail, true)
                                    )
                                }
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                Log.e("SupabaseService", "getOrCreateGoogleProfile error: ${e.message}")
            }
        }

        // If not in Supabase yet, return clean synchronized profile and upsert into Supabase profiles
        val initialName = displayName ?: cleanEmail.substringBefore("@").replace(".", " ").capitalizeWords().ifBlank { "Campus Student" }
        val initialAvatar = avatarUrl ?: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&h=300&fit=crop"
        val newProfile = UserProfile(
            id = "user_${System.currentTimeMillis() % 100000}",
            fullName = initialName,
            username = derivedUsername,
            email = ContactField(cleanEmail, true),
            avatarUrl = initialAvatar,
            verificationBadge = VerificationBadge.BLUE,
            faculty = "SIMME",
            department = "Systems Engineering",
            university = "University of Lagos (UNILAG)",
            academicLevel = "400 Level",
            bio = "Active campus student & tech builder on Blink 🚀"
        )

        try {
            val json = JSONObject().apply {
                put("email", cleanEmail)
                put("username", derivedUsername)
                put("full_name", initialName)
                put("avatar_url", initialAvatar)
                put("faculty", "SIMME")
                put("university", "University of Lagos")
                put("verification_tier", 1)
            }
            val req = newRequestBuilder("/rest/v1/profiles")
                .addHeader("Prefer", "resolution=merge-duplicates")
                .post(json.toString().toRequestBody(jsonMediaType))
                .build()
            client.newCall(req).execute().close()
        } catch (_: Exception) {}

        return@withContext newProfile
    }

    suspend fun createFeedPost(
        author: String,
        authorAvatar: String,
        facultyTag: String,
        text: String,
        imageUrl: String?,
        videoUrl: String? = null,
        tags: List<String> = emptyList(),
        mentions: List<String> = emptyList(),
        poll: PostPoll? = null,
        isReel: Boolean = false
    ): Boolean = withContext(Dispatchers.IO) {
        try {
            val json = JSONObject().apply {
                put("type", if (isReel || !videoUrl.isNullOrBlank()) "reel" else if (!imageUrl.isNullOrBlank()) "photo" else "text")
                put("faculty", facultyTag.ifBlank { "SIMME" })
                put("text", text)
                if (!imageUrl.isNullOrBlank()) {
                    put("image_url", imageUrl)
                }
                if (!videoUrl.isNullOrBlank()) {
                    put("video_url", videoUrl)
                }
                if (tags.isNotEmpty()) {
                    put("tags", JSONArray(tags))
                }
                if (mentions.isNotEmpty()) {
                    put("mentions", JSONArray(mentions))
                }
                if (poll != null) {
                    val pollJson = JSONObject().apply {
                        put("question", poll.question)
                        val optArray = JSONArray()
                        poll.options.forEach { opt ->
                            optArray.put(JSONObject().apply {
                                put("id", opt.id)
                                put("text", opt.text)
                                put("votes", opt.votes)
                            })
                        }
                        put("options", optArray)
                    }
                    put("poll_data", pollJson.toString())
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
                                // Attach badge object transiently to use it later
                                obj.put("_parsedBadge", extractBadge(obj).name)
                                convosMap.getOrPut(partner) { mutableListOf() }.add(msg)
                            }

                            val conversations = convosMap.map { (partner, msgs) ->
                                // Try to find badge from any associated message raw obj that had it
                                val badgeName = jsonArray.let { arr ->
                                    var found = "NONE"
                                    for (i in 0 until arr.length()) {
                                        val o = arr.optJSONObject(i)
                                        if (o != null) {
                                            val s = o.optString("sender_username", o.optString("sender_id", "user"))
                                            val r = o.optString("receiver_username", "you")
                                            if ((s == partner || r == partner) && o.has("_parsedBadge")) {
                                                found = o.optString("_parsedBadge")
                                                if (found != "NONE") break
                                            }
                                        }
                                    }
                                    found
                                }
                                val badge = VerificationBadge.valueOf(badgeName)

                                ChatConversation(
                                    id = "conv_$partner",
                                    partnerUsername = partner,
                                    partnerName = partner.replace(".", " ").replace("_", " ").capitalizeWords(),
                                    partnerAvatar = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop",
                                    isOnline = true,
                                    lastMessage = msgs.firstOrNull()?.text ?: "",
                                    lastMessageTime = msgs.firstOrNull()?.timestamp ?: "Just now",
                                    unreadCount = 0,
                                    isVerified = badge != VerificationBadge.NONE,
                                    verificationBadge = badge,
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
        val viewsCount = obj.optInt("view_count", obj.optInt("views", 120))
        val videoUrl = obj.optString("video_url", obj.optString("videoUrl", "")).ifBlank { null }
        val createdAt = obj.optString("created_at", "")

        val tagsList = mutableListOf<String>()
        val tagsArr = obj.optJSONArray("tags")
        if (tagsArr != null) {
            for (i in 0 until tagsArr.length()) {
                val t = tagsArr.optString(i)
                if (t.isNotBlank()) tagsList.add(t)
            }
        }

        val mentionsList = mutableListOf<String>()
        val mentionsArr = obj.optJSONArray("mentions")
        if (mentionsArr != null) {
            for (i in 0 until mentionsArr.length()) {
                val m = mentionsArr.optString(i)
                if (m.isNotBlank()) mentionsList.add(m)
            }
        }

        var postPoll: PostPoll? = null
        val pollDataRaw = obj.optString("poll_data", "")
        if (pollDataRaw.isNotBlank()) {
            try {
                val pollObj = JSONObject(pollDataRaw)
                val q = pollObj.optString("question", "Campus Poll")
                val optArr = pollObj.optJSONArray("options")
                val options = mutableListOf<PollOption>()
                var totalVotes = 0
                if (optArr != null) {
                    for (i in 0 until optArr.length()) {
                        val optO = optArr.optJSONObject(i) ?: continue
                        val optId = optO.optString("id", "opt_$i")
                        val optText = optO.optString("text", "Option ${i + 1}")
                        val optVotes = optO.optInt("votes", 0)
                        totalVotes += optVotes
                        options.add(PollOption(optId, optText, optVotes, false))
                    }
                }
                if (options.isNotEmpty()) {
                    postPoll = PostPoll(q, options, totalVotes, false)
                }
            } catch (_: Exception) {}
        }

        val badge = extractBadge(obj)

        return FeedPost(
            id = id,
            author = author,
            authorAvatar = avatar,
            facultyTag = faculty,
            isVerified = badge != VerificationBadge.NONE,
            verificationBadge = badge,
            timeAgo = formatTimeAgo(createdAt),
            text = text,
            images = if (imageUrl.isNotBlank()) listOf(imageUrl) else emptyList(),
            likes = likes,
            isLiked = false,
            commentsCount = comments,
            sharesCount = shares,
            viewsCount = viewsCount,
            isReel = isReel,
            videoUrl = videoUrl,
            tags = tagsList,
            mentions = mentionsList,
            poll = postPoll
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

    private fun extractBadge(obj: JSONObject): VerificationBadge {
        val followerCount = obj.optInt("follower_count", 0)
        val profileViews = obj.optInt("profile_views", 0)
        
        val verifiedAtStr = obj.optString("verified_at", "")
        var verifiedAtMillis = 0L
        if (verifiedAtStr.isNotBlank()) {
            try {
                val format = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", java.util.Locale.US)
                format.timeZone = java.util.TimeZone.getTimeZone("UTC")
                verifiedAtMillis = format.parse(verifiedAtStr)?.time ?: 0L
            } catch (e: Exception) {
            }
        }
        
        if (verifiedAtMillis == 0L && followerCount >= 800) {
            verifiedAtMillis = System.currentTimeMillis() - java.util.concurrent.TimeUnit.DAYS.toMillis(1)
        }
        
        val thirtyDaysMillis = 30L * 24 * 60 * 60 * 1000
        val isExpired = System.currentTimeMillis() - verifiedAtMillis > thirtyDaysMillis
        
        if (isExpired && followerCount < 800) {
            return VerificationBadge.NONE
        } else {
            val dbBadge = obj.optString("verification_badge", "").uppercase()
            if (dbBadge == "GOLD" || (followerCount >= 1000 && profileViews >= 2000)) {
                return VerificationBadge.GOLD
            } else if (dbBadge == "BLUE" || followerCount >= 800) {
                return VerificationBadge.BLUE
            } else {
                return VerificationBadge.NONE
            }
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

        val followerCount = obj.optInt("follower_count", 2450)
        val followingCount = obj.optInt("following_count", 380)
        val profileViews = obj.optInt("profile_views", 312)
        
        val badge = extractBadge(obj)
        val verifiedAtMillis = if (badge != VerificationBadge.NONE) System.currentTimeMillis() else 0L

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
            verificationBadge = badge,
            verifiedAtMillis = verifiedAtMillis,
            followerCount = followerCount,
            followingCount = followingCount,
            profileViewsThisWeek = profileViews,
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
            streakDays = obj.optInt("streak_days", 14),
            verificationBadge = extractBadge(obj)
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

        val badge = extractBadge(obj)

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
            sellerIsVerified = badge != VerificationBadge.NONE,
            verificationBadge = badge,
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
