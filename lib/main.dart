import 'package:flutter/material.dart';
import 'package:projetofinal/app1/list.dart';
import 'login.dart';
import 'intermed.dart';
import 'app1/main_manage_prop.dart';
import 'app2/rent_prop.dart';
import 'app2/each_prop.dart';
import 'app2/reservations.dart';
import 'app1/create.dart';
import 'app1/delete.dart';
import 'app1/edit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // Define a rota inicial
      routes: {
        '/': (context) => LoginScreen(),
        '/intermed': (context) => Intermediario(),
        '/manage_prop': (context) => ManageProperty(),
        '/rent_prop': (context) => RentProperty(),
        '/create_prop': (context) => CreatePropertyScreen(),
        '/list_prop': (context) => ListPropertiesScreen(),
        '/delete_prop': (context) => DeletePropertiesScreen(),
        '/edit_prop': (context) => EditPropertiesScreen(),
        '/each_prop': (context) => EachProperty(),
        '/reservations': (context) => Reservations(),
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
