package com.example.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
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
import com.example.data.models.FeedPost
import com.example.ui.components.FacultyBadge
import com.example.ui.theme.BlinkPink

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SearchScreen(
    posts: List<FeedPost>,
    onProfileClick: (String) -> Unit,
    onPostClick: (FeedPost) -> Unit,
    isDark: Boolean
) {
    var searchQuery by remember { mutableStateOf("") }
    var selectedTag by remember { mutableStateOf("All") }

    val trendingTags = listOf("All", "#UNILAG", "#AlutaMarket", "#CampusGala2026", "#TechLagos", "#SIMME", "#MootCourt", "#DesignWeek")
    val facultyFilters = listOf("SIMME", "ENGINEERING", "LAW", "ARTS", "SCIENCE", "MEDICINE")

    val filteredPosts = remember(searchQuery, selectedTag, posts) {
        posts.filter { post ->
            val matchQuery = searchQuery.isBlank() ||
                    post.text.contains(searchQuery, ignoreCase = true) ||
                    post.author.contains(searchQuery, ignoreCase = true) ||
                    post.facultyTag.contains(searchQuery, ignoreCase = true)
            val matchTag = selectedTag == "All" ||
                    post.text.contains(selectedTag.replace("#", ""), ignoreCase = true) ||
                    post.facultyTag.equals(selectedTag, ignoreCase = true)
            matchQuery && matchTag
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(top = 44.dp)
            .testTag("search_screen")
    ) {
        // Search Input Bar
        Surface(
            color = if (isDark) MaterialTheme.colorScheme.surfaceVariant else Color(0xFFEFEFF4),
            shape = RoundedCornerShape(100.dp),
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 8.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(horizontal = 16.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.Search,
                    contentDescription = "Search",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
                TextField(
                    value = searchQuery,
                    onValueChange = { searchQuery = it },
                    placeholder = {
                        Text(
                            "Search students, posts, #tags, faculties...",
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            fontSize = 13.5.sp
                        )
                    },
                    keyboardOptions = androidx.compose.foundation.text.KeyboardOptions(
                        imeAction = androidx.compose.ui.text.input.ImeAction.Search,
                        autoCorrectEnabled = true
                    ),
                    singleLine = true,
                    colors = TextFieldDefaults.colors(
                        focusedContainerColor = Color.Transparent,
                        unfocusedContainerColor = Color.Transparent,
                        focusedIndicatorColor = Color.Transparent,
                        unfocusedIndicatorColor = Color.Transparent
                    ),
                    modifier = Modifier
                        .weight(1f)
                        .testTag("search_text_input")
                )
                if (searchQuery.isNotEmpty()) {
                    IconButton(onClick = { searchQuery = "" }) {
                        Icon(
                            imageVector = Icons.Default.Close,
                            contentDescription = "Clear",
                            tint = MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier = Modifier.size(18.dp)
                        )
                    }
                }
            }
        }

        // Trending Tags Carousel
        LazyRow(
            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 6.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(trendingTags) { tag ->
                val selected = selectedTag == tag
                Surface(
                    shape = RoundedCornerShape(100.dp),
                    color = if (selected) BlinkPink else (if (isDark) MaterialTheme.colorScheme.surface else Color(0xFFECEFF1)),
                    modifier = Modifier.clickable { selectedTag = tag }
                ) {
                    Text(
                        text = tag,
                        fontSize = 12.sp,
                        fontWeight = if (selected) FontWeight.Bold else FontWeight.Medium,
                        color = if (selected) Color.White else MaterialTheme.colorScheme.onSurface,
                        modifier = Modifier.padding(horizontal = 14.dp, vertical = 7.dp)
                    )
                }
            }
        }

        // Campus Explore Grid
        LazyVerticalGrid(
            columns = GridCells.Fixed(2),
            contentPadding = PaddingValues(start = 16.dp, end = 16.dp, top = 10.dp, bottom = 120.dp),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
            modifier = Modifier.fillMaxSize()
        ) {
            items(filteredPosts) { post ->
                Card(
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable { onPostClick(post) }
                ) {
                    Column {
                        if (post.images.isNotEmpty()) {
                            AsyncImage(
                                model = post.images[0],
                                contentDescription = post.text,
                                contentScale = ContentScale.Crop,
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(130.dp)
                            )
                        } else {
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(100.dp)
                                    .background(BlinkPink.copy(alpha = 0.15f))
                                    .padding(12.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = post.text.take(60) + "...",
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.Medium,
                                    color = MaterialTheme.colorScheme.onSurface
                                )
                            }
                        }

                        Column(modifier = Modifier.padding(10.dp)) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(6.dp),
                                modifier = Modifier.clickable { onProfileClick(post.author) }
                            ) {
                                AsyncImage(
                                    model = post.authorAvatar,
                                    contentDescription = post.author,
                                    contentScale = ContentScale.Crop,
                                    modifier = Modifier
                                        .size(20.dp)
                                        .clip(CircleShape)
                                )
                                Text(
                                    text = post.author,
                                    fontSize = 11.5.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = MaterialTheme.colorScheme.onSurface
                                )
                            }

                            Spacer(modifier = Modifier.height(6.dp))

                            FacultyBadge(tag = post.facultyTag)
                        }
                    }
                }
            }
        }
    }
}
