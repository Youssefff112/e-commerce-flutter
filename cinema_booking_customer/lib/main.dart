import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/mock_data_service.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/movies_list_screen.dart';
import 'screens/bookings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final authService = AuthService();
  await authService.loadUser();

  final dataService = MockDataService();
  dataService.initialize();

  runApp(MyApp(authService: authService, dataService: dataService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final MockDataService dataService;

  const MyApp(
      {super.key, required this.authService, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MockDataService>.value(value: dataService),
        Provider<AuthService>.value(value: authService),
      ],
      child: MaterialApp(
        title: 'Cinema Booking - Customer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          useMaterial3: true,
        ),
        home: authService.isLoggedIn
            ? const MoviesListScreen()
            : const LoginScreen(),
        routes: {
          '/movies': (_) => const MoviesListScreen(),
          '/login': (_) => const LoginScreen(),
          '/bookings': (_) => const BookingsScreen(),
        },
      ),
    );
  }
}
