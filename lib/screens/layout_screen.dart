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
      const WishlistPage(),
      const AuctionPage(),
      const ProfileScreen(),
    ];
  }

  void _onTabTapped(BuildContext context, int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (index == 3 && !authProvider.isAuthenticated) {
      // Profile tab index
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return; // Exit the function to prevent setting the selected index
    }

    setState(() {
      selectedIndex = index;
    });
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.search),
        title: "Explore",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.favorite_outline),
        title: ("Wishlist"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.warehouse_outlined),
        title: ("Auctions"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.account_circle_outlined),
        title: ("Profile"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<Widget> _screens() {
    return [
      const HomePage(),
      const Center(child: Text('Wishlists')),
      const AuctionPage(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[selectedIndex],
      bottomNavigationBar: PersistentTabView(
        context,
        controller: _controller,
        screens: _screens(),
        items: _navBarItems(),
        backgroundColor: Colors.white,
        navBarStyle: NavBarStyle.style9,
      ),
    );
  }
}
