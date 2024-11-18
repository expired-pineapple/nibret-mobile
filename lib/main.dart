import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nibret/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:nibret/screens/home_page.dart';
import 'package:nibret/provider/auth_provider.dart';
import 'package:nibret/screens/login_screen.dart'; // Make sure to import your login screen

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInit = true;
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      for (var i = 1; i <= 6; i++) {
        precacheImage(
          Image.asset('assets/images/listing-$i.jpg').image,
          context,
        );
      }
      for (var i = 1; i <= 3; i++) {
        precacheImage(
          Image.asset('assets/images/person-$i.jpeg').image,
          context,
        );
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _onTabTapped(BuildContext context, int index) {
    if (index == 3) {
      // Profile tab index
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return;
      }
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..loadUserFromPrefs(),
      child: MaterialApp(
        title: 'Nibret',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          body: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return IndexedStack(
                index: _currentIndex,
                children: const [
                  HomePage(),
                  Center(child: Text('Wishlists')),
                  Center(child: Text('Auctions')),
                  ProfileScreen(),
                ],
              );
            },
          ),
          bottomNavigationBar: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return BottomNavigationBar(
                currentIndex: _currentIndex,
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
                    icon: Icon(Icons.gavel_outlined),
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
        ),
      ),
    );
  }
}
