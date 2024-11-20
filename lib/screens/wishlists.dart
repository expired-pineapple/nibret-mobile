import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:nibret/provider/favorite_provider.dart';

class Wishlists extends StatelessWidget {
  const Wishlists({super.key});

  Future<Map<String, dynamic>?> fetchFavoriteItem(String itemId) async {
    try {
      final response = await http.get(
        Uri.parse('https://nibret-backend-1.onrender.com/wishlist/'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load item');
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    final favoriteItems = provider.favorites;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Edit",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                const Text(
                  "Wishlists",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                favoriteItems.isEmpty
                    ? const Text(
                        "No Favorites items yet",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.68,
                        child: GridView.builder(
                          itemCount: favoriteItems.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            String favorite = favoriteItems[index];
                            return FutureBuilder<Map<String, dynamic>?>(
                              future: fetchFavoriteItem(favorite),
                              builder: (context, snapShot) {
                                if (snapShot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (!snapShot.hasData ||
                                    snapShot.data == null) {
                                  return const Center(
                                    child: Text("Error loading favorites"),
                                  );
                                }
                                var favoriteItem = snapShot.data!;
                                return Stack(
                                  children: [
                                    // image of favorite items
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                            favoriteItem[
                                                'image'], // Adjust according to your API response
                                          ),
                                        ),
                                      ),
                                    ),
                                    // favorite icon in the top right corner
                                    const Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                      ),
                                    ),
                                    // title of favorite items
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      right: 8,
                                      child: Container(
                                        color: Colors.black.withOpacity(0.6),
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          favoriteItem[
                                              'title'], // Adjust according to your API response
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
