import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'data/app_state.dart';

// Auth screens
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';

// Home & Concert screens
import 'screens/home/home_screen.dart';
import 'screens/concert/create_concert_screen.dart';
import 'screens/concert/join_concert_screen.dart';
import 'screens/concert/concert_detail_screen.dart';

// Feature screens
import 'screens/tasks/create_task_screen.dart';
import 'screens/artists/add_artist_screen.dart';
import 'screens/staff/add_staff_screen.dart';
import 'screens/status/status_board_screen.dart';
import 'screens/incidents/incidents_screen.dart';
import 'screens/incidents/log_incident_screen.dart';
import 'screens/notes/notes_screen.dart';
import 'screens/budget/budget_screen.dart';
import 'screens/budget/add_expense_screen.dart';
import 'screens/emergency/emergency_contacts_screen.dart';
import 'screens/summary/summary_screen.dart';

final AppState _appState = AppState();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  _appState.initializeAuth();
  runApp(const StageSyncApp());
}

class StageSyncApp extends StatelessWidget {
  const StageSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StageSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.splash:
            return _fade(SplashScreen(appState: _appState));

          case AppRoutes.login:
            return _fade(LoginScreen(appState: _appState));

          case AppRoutes.signup:
            return _slide(SignupScreen(appState: _appState));

          case AppRoutes.home:
            return _fade(HomeScreen(appState: _appState));

          case AppRoutes.createConcert:
            return _slide(CreateConcertScreen(appState: _appState));

          case AppRoutes.joinConcert:
            return _slide(JoinConcertScreen(appState: _appState));

          case AppRoutes.concertDetail:
            final concertId = settings.arguments as String;
            return _slide(ConcertDetailScreen(
                appState: _appState, concertId: concertId));

          case AppRoutes.createTask:
            final concertId = settings.arguments as String;
            return _slide(CreateTaskScreen(
                appState: _appState, concertId: concertId));

          case AppRoutes.addArtist:
            final concertId = settings.arguments as String;
            return _slide(AddArtistScreen(
                appState: _appState, concertId: concertId));

          case AppRoutes.addStaff:
            final concertId = settings.arguments as String;
            return _slide(AddStaffScreen(
                appState: _appState, concertId: concertId));

          case AppRoutes.statusBoard:
            final concertId = settings.arguments as String;
            return _slide(StatusBoardScreen(
                appState: _appState, concertId: concertId));

          case AppRoutes.incidents:
            final concertId = settings.arguments as String;
            return _slide(IncidentsScreen(
                appState: _appState, concertId: concertId));

          case AppRoutes.logIncident:
            final concertId = settings.arguments as String;
            return _slide(LogIncidentScreen(
                appState: _appState, concertId: concertId));

          case AppRoutes.notes:
            final concertId = settings.arguments as String;
            return _slide(NotesScreen(
                appState: _appState, concertId: concertId));

          case AppRoutes.budget:
            final concertId = settings.arguments as String;
            return _slide(BudgetScreen(
                appState: _appState, concertId: concertId));

          case AppRoutes.addExpense:
            final concertId = settings.arguments as String;
            return _slide(AddExpenseScreen(
                appState: _appState, concertId: concertId));

          case AppRoutes.emergencyContacts:
            final concertId = settings.arguments as String;
            return _slide(EmergencyContactsScreen(
                appState: _appState, concertId: concertId));

          case AppRoutes.summary:
            final concertId = settings.arguments as String;
            return _slide(SummaryScreen(
                appState: _appState, concertId: concertId));

          default:
            return _fade(SplashScreen(appState: _appState));
        }
      },
    );
  }

  // Fade transition
  PageRouteBuilder _fade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondary) => page,
      transitionsBuilder: (context, animation, secondary, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Slide-up transition
  PageRouteBuilder _slide(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondary) => page,
      transitionsBuilder: (context, animation, secondary, child) {
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
