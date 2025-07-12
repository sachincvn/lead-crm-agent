import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'presentation/bloc/lead_bloc.dart';
import 'presentation/screens/leads_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lead CRM Agent',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light), useMaterial3: true, appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0), cardTheme: CardTheme(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))), outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))), inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true)),
      darkTheme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark), useMaterial3: true, appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0), cardTheme: CardTheme(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))), outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))), inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true)),
      themeMode: ThemeMode.system,
      home: BlocProvider(create: (context) => getIt<LeadBloc>(), child: const LeadsScreen()),
    );
  }
}
