import 'package:flutter/material.dart';
import 'package:mobile_money_transfert/screen/test__api_screen.dart';
import 'services/app_initializer.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les services
  await AppInitializer.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Transfer App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: TestApiScreen(),
    );
  }
}