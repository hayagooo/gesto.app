import 'package:flutter/material.dart';
import 'package:gestoapp/route_generator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gestoapp/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build (BuildContext context) {
    return MaterialApp(
      title: 'Gesto App',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: Color.fromARGB(255, 244, 244, 244),
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGeneator.generateRoute,
    );
  }
}