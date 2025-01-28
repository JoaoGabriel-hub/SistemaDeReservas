import 'package:flutter/material.dart';

class CreateProperty extends StatefulWidget {
  @override
  _CreatePropertyState createState() => _CreatePropertyState();
}

class _CreatePropertyState extends State<CreateProperty> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Property'),
      ),
      body: Center(
        child: Text('Create Property Screen'),
      ),
    );
  }
}