import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/config/theme.dart';
import 'package:social_media_app/screens/home_screen.dart';
import 'package:social_media_app/screens/chat_screen.dart';
import 'package:social_media_app/screens/inbox_screen.dart';
import 'package:social_media_app/screens/splash_screen.dart';
import 'package:social_media_app/screens/profile_screen.dart';
import 'package:social_media_app/screens/explore_screen.dart';
import 'package:social_media_app/screens/settings_screen.dart';
import 'package:social_media_app/services/chattr_backend.dart';
import 'package:social_media_app/providers/feed_provider.dart';
import 'package:social_media_app/providers/theme_provider.dart';
import 'package:social_media_app/providers/media_provider.dart';
import 'package:social_media_app/screens/create_post_screen.dart';
import 'package:social_media_app/providers/privacy_provider.dart';
import 'package:social_media_app/providers/creator_provider.dart';
import 'package:social_media_app/services/notification_service.dart';
import 'package:social_media_app/screens/auth/login_signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ChattrBackend>(
          create: (_) => ChattrBackend(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<PrivacyProvider>(
          create: (_) => PrivacyProvider(),
        ),
        ChangeNotifierProvider<CreatorProvider>(
          create: (_) => CreatorProvider(),
        ),
        ChangeNotifierProvider<FeedProvider>(
          create: (_) => FeedProvider(),
        ),
        ChangeNotifierProvider<MediaProvider>(
          create: (_) => MediaProvider(),
        ),
        Provider<NotificationService>(
          create: (_) => NotificationService(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final themeProvider = context.watch<ThemeProvider>();
          return MaterialApp(
            title: 'Chattr',
            theme: AppTheme.darkTheme.copyWith(
              colorScheme: ColorScheme.dark(
                primary: themeProvider.currentColor.color,
                background: Colors.black,
              ),
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const AuthWrapper(),
              '/login': (context) => const LoginSignupScreen(),
              '/home': (context) => const MainScreen(),
              '/create_post': (context) => const CreatePostScreen(),
              '/chat': (context) => const ChatScreen(
                receiverId: '',
                receiverName: '',
                receiverProfilePic: '',
              ),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        
        if (snapshot.hasData) {
          return const MainScreen();
        }
        
        return const LoginSignupScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreScreen(),
    const InboxScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeColor = context.watch<ThemeProvider>().currentColor.color;
    
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: themeColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create_post'),
        backgroundColor: themeColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
