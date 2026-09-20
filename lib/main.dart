import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Theme imports
import 'themes/app_theme.dart';

// Provider imports
import 'providers/providers.dart';
import 'providers/lawyer_provider.dart';

// Screen imports
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/voice/voice_screen.dart';
import 'screens/call/call_screen.dart';
import 'screens/legal/legal_topics_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/lawyer/lawyer_discovery_screen.dart';
import 'screens/lawyer/lawyer_profile_screen.dart';
import 'screens/profile/user_profile_screen.dart';

// Service imports
import 'services/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services
  await DatabaseService().database;
  await VoiceService().initialize();

  runApp(const RightlyApp());
}

/// Rightly - AI Legal Awareness Assistant
/// A premium, production-ready Flutter application
class RightlyApp extends StatelessWidget {
  const RightlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => VoiceProvider()),
        ChangeNotifierProvider(create: (_) => CallProvider()),
        ChangeNotifierProvider(create: (_) => LawyerProvider()),
      ],
      child: MaterialApp(
        title: 'Rightly - AI Legal Assistant',
        debugShowCheckedModeBanner: false,
        
        // Theme configuration
        theme: AppTheme.light,
        
        // Initial route
        initialRoute: AppRoutes.splash,
        
        // Route generation
        onGenerateRoute: AppRoutes.generateRoute,
        
        // Builder for global configuration
        builder: (context, child) {
          // Apply global text scale factor limits
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.4),
              ),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}


/// App Route Names
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String chat = '/chat';
  static const String voice = '/voice';
  static const String call = '/call';
  static const String legalTopics = '/legal-topics';
  static const String settings = '/settings';
  static const String lawyerDiscovery = '/lawyer-discovery';
  static const String lawyerProfile = '/lawyer-profile';
  static const String userProfile = '/user-profile';

  /// Generate route based on settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen());
      case onboarding:
        return _buildRoute(const OnboardingScreen());
      case auth:
        return _buildRoute(const AuthScreen());
      case login:
        return _buildRoute(const LoginScreen());
      case register:
        return _buildRoute(const RegisterScreen());
      case forgotPassword:
        return _buildRoute(const ForgotPasswordScreen());
      case dashboard:
        return _buildRoute(const DashboardScreen());
      case chat:
        return _buildRoute(const ChatScreen());
      case voice:
        return _buildRoute(const VoiceAssistantScreen());
      case call:
        return _buildRoute(const CallAgentScreen());
      case legalTopics:
        return _buildRoute(const LegalTopicsScreen());
      case AppRoutes.settings:
        return _buildRoute(const SettingsScreen());
      case lawyerDiscovery:
        return _buildRoute(const LawyerDiscoveryScreen());
      case lawyerProfile:
        final lawyerId = settings.arguments as String? ?? '';
        return _buildRoute(LawyerProfileScreen(lawyerId: lawyerId));
      case userProfile:
        return _buildRoute(const UserProfileScreen());
      default:
        return _buildRoute(const SplashScreen());
    }
  }

  /// Build custom page route with slide transition
  static PageRouteBuilder _buildRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
