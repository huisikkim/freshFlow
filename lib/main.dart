import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/injection_container.dart';
import 'package:fresh_flow/presentation/pages/login_page.dart';
import 'package:fresh_flow/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InjectionContainer.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => InjectionContainer.getAuthProvider()),
        ChangeNotifierProvider(
            create: (_) => InjectionContainer.getCartProvider()),
        ChangeNotifierProvider(
            create: (_) => InjectionContainer.getOrderProvider()),
        ChangeNotifierProvider(
            create: (_) => InjectionContainer.getChatProvider()),
        ChangeNotifierProvider(
            create: (_) => InjectionContainer.getDeliveryProvider()),
        ChangeNotifierProvider(
            create: (_) => InjectionContainer.getReviewProvider()),
      ],
      child: MaterialApp(
        title: 'Fresh Flow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}
