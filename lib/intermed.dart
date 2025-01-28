import 'package:flutter/material.dart';

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
        child: 
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              // Add your onPressed code here!
            },
            child: Text('Cadastrar propriedade'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Add your onPressed code here!
            },
            child: Text('Reservar propriedade'),
          ),
        ],
      )
      ),
    );
  }
}