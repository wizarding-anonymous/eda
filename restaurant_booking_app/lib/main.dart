import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/auth/auth_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize dependency injection
  await configureDependencies();
  
  // Initialize authentication manager
  await AuthManager.instance.initialize();
  
  runApp(const ProviderScope(child: RestaurantBookingApp()));
}

class RestaurantBookingApp extends ConsumerWidget {
  const RestaurantBookingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'Restaurant Booking',
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}