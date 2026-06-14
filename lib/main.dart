import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_dashboard_screen.dart';
import 'admin_orders_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://beyqwacqwzungcookdox.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJleXF3YWNxd3p1bmdjb29rZG94Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzMjkyNzksImV4cCI6MjA5NjkwNTI3OX0.3g3G5eb3h56o77XBX3tMqEEBdznkPSpeUSTdZ-WVQK0',
  );

  runApp(const PharmaAdminApp());
}

class PharmaAdminApp extends StatelessWidget {
  const PharmaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pharma Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor:
            const Color(0xFFF5F7FA),
      ),
      home: const AdminDashboardScreen(),
    );
  }
}