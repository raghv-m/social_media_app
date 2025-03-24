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
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme.copyWith(
              colorScheme: ColorScheme.dark(
                primary: themeProvider.currentColor.color,
                background: Colors.black,
              ),
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: ZoomPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(
                    builder: (_) => const AuthWrapper(),
                  );
                case '/login':
                  return MaterialPageRoute(
                    builder: (_) => const LoginSignupScreen(),
                  );
                case '/home':
                  return MaterialPageRoute(
                    builder: (_) => const MainScreen(),
                  );
                case '/create_post':
                  return PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => 
                      const CreatePostScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOutCubic;
                      var tween = Tween(begin: begin, end: end).chain(
                        CurveTween(curve: curve),
                      );
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  );
                case '/chat':
                  final args = settings.arguments as Map<String, String>;
                  return MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      receiverId: args['receiverId'] ?? '',
                      receiverName: args['receiverName'] ?? '',
                      receiverProfilePic: args['receiverProfilePic'] ?? '',
                    ),
                  );
                case '/settings':
                  return MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  );
                default:
                  return MaterialPageRoute(
                    builder: (_) => const AuthWrapper(),
                  );
              }
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

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreScreen(),
    const InboxScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = context.watch<ThemeProvider>().currentColor.color;
    
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          _controller.forward(from: 0);
        },
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
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticOut,
        )),
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/create_post'),
          backgroundColor: themeColor,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
