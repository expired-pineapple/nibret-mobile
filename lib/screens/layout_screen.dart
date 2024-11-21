import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nibret/provider/auth_provider.dart';
import 'package:nibret/screens/auction_page.dart';
import 'package:nibret/screens/home_page.dart';
import 'package:nibret/screens/login_screen.dart';
import 'package:nibret/screens/profile_screen.dart';
import 'package:nibret/screens/wishlist_screen.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      const HomePage(),
      WishlistPage(),
      const AuctionPage(),
      const ProfileScreen(),
    ];
  }

  void _onTabTapped(BuildContext context, int index) {
    if (index == 3) {
      // Profile tab index
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        return; // Exit the function to prevent setting the selected index
      }
    }
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return BottomNavigationBar(
            currentIndex: selectedIndex,
            elevation: 5,
            iconSize: 32,
            onTap: (index) => _onTabTapped(context, index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF0A3B81),
            unselectedItemColor: Colors.grey[400],
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: "Explore",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline),
                label: "Wishlists",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.warehouse_outlined),
                label: "Auctions",
              ),
              BottomNavigationBarItem(
                icon: Icon(authProvider.isAuthenticated
                    ? Icons.account_circle
                    : Icons.account_circle_outlined),
                label: "Profile",
              ),
            ],
          );
        },
      ),
      body: pages[selectedIndex],
    );
  }
}
