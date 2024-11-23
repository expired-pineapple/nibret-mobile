import 'package:flutter/material.dart';
import 'package:nibret/provider/auth_provider.dart';
import 'package:nibret/screens/auction_page.dart';
import 'package:nibret/screens/home_page.dart';
import 'package:nibret/screens/login_screen.dart';
import 'package:nibret/screens/profile_screen.dart';
import 'package:nibret/screens/wishlist_page.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _buildScreens() {
    return [
      const HomePage(),
      const WishlistPage(),
      const AuctionPage(),
      const ProfileScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.search),
        title: "Explore",
        activeColorPrimary: const Color(0XFF163C9F),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.favorite_outline),
        title: "Wishlist",
        activeColorPrimary: const Color(0XFF163C9F),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.warehouse_outlined),
        title: "Auctions",
        activeColorPrimary: const Color(0XFF163C9F),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.account_circle_outlined),
        title: "Profile",
        activeColorPrimary: const Color(0XFF163C9F),
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarItems(),
        backgroundColor: Colors.white,
        navBarStyle: NavBarStyle.style9,
        onItemSelected: (index) {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);

          if (index == 3 && !authProvider.isAuthenticated) {
            // Navigate to login screen while preserving the desired tab index
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            ).then((value) {
              // After login, if successful, the user will be redirected back here
              // The controller will maintain the selected index
              if (authProvider.isAuthenticated) {
                _controller.index = 3; // Set to profile tab
              } else {
                _controller.index =
                    0; // Reset to home tab if login was cancelled
              }
            });
          }
        },
      ),
    );
  }
}
