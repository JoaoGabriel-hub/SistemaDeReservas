import 'package:flutter/material.dart';
import 'login.dart';
import 'intermed.dart'; // Certifique-se de que o arquivo intermed.dart está no local correto

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // Define a rota inicial
      routes: {
        '/': (context) => LoginScreen(),
        '/intermed': (context) => Intermediario(), // Registra a rota intermed
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('Erro')),
            body: Center(
              child: Text('Rota não encontrada: ${settings.name}'),
            ),
          ),
        );
      },
    );
  }
}
