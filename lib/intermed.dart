import 'package:flutter/material.dart';
//import 'package:projetofinal/logged_user.dart';

class Intermediario extends StatefulWidget {
  @override
  _IntermediarioState createState() => _IntermediarioState();
}

class _IntermediarioState extends State<Intermediario> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Intermediario'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/manage_prop');
              },
              child: Text('Gerenciar suas propriedades'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/rent_prop');
              },
              child: Text('Reservar propriedade'),
            ),
          ],
        )
      ),
    );
  }
}
