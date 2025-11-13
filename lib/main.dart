import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/utils/logger.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  // Initialize logger
  AppLogger.info('Starting Restaurant Admin Flutter App');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth provider - should be first as others may depend on it
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Other providers
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        title: 'Restaurant Admin',
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // Home
        home: const AuthenticationWrapper(),
      ),
    );
  }
}

/// Wrapper to handle authentication state
/// Shows login screen if not authenticated, otherwise shows home screen
class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  @override
  void initState() {
    super.initState();
    // Check authentication status on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuthentication();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading while checking authentication
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        // Show home screen if authenticated, otherwise show login
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
