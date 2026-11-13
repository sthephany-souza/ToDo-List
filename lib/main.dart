import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routes.dart';

void main() async {
  // Garante a inicialização correta dos bindings do Flutter antes do código assíncrono
  WidgetsFlutterBinding.ensureInitialized();
  
  // Conecta ao Supabase antes de subir a interface visual
  await Supabase.initialize(
    url: 'https://oxqbosxvljhztoxfvyfv.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im94cWJvc3h2bGpoenRveGZ2eWZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQ1NDgzMTcsImV4cCI6MjExMDEyNDMxN30.P6UsOvmUPcCxsFErhbvx33xZEapSiMUKHjwQBsi231k',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda de Compromissos',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: Routes.login, // Tela inicial da aplicação
      routes: Routes.getRoutes(), // Rotas centralizadas
      debugShowCheckedModeBanner: false,
    );
  }
}