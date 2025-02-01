import 'package:flutter/material.dart';

class ManageProperty extends StatefulWidget {
  @override
  _ManagePropertyState createState() => _ManagePropertyState();
}

class _ManagePropertyState extends State<ManageProperty> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Property'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Add your create property logic here
                Navigator.pushNamed(context, '/create_prop');
              },
              child: Text('Criar Propriedade'),
            ),
            SizedBox(height: 20), // Espaçamento adicionado
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/list_prop');
              },
              child: Text('Listar Propriedades'),
            ),
            SizedBox(height: 20), // Espaçamento adicionado
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/delete_prop');
              },
              child: Text('Remover Propriedade'),
            ),
            SizedBox(height: 20), // Espaçamento adicionado
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/edit_prop');
              },
              child: Text('Editar Propriedade'),
            ),
          ],
        ),
      ),
    );
  }
}
