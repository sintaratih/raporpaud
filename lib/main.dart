
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lxnzmrbdyiokienblhra.supabase.co',
    publishableKey: 'sb_publishable_syPrTniiEmV0cxJdZXt4vg_ztg7HEvy',
  );

  runApp(const RaporPAUD());
}

class RaporPAUD extends StatelessWidget {
  const RaporPAUD({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RaporPAUD',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F7FC),
        primaryColor: const Color(0xFF1765D9),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
