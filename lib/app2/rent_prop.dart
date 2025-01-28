import 'package:flutter/material.dart';

class RentProperty extends StatefulWidget {
  @override
  _RentPropertyState createState() => _RentPropertyState();
}


class _RentPropertyState extends State<RentProperty> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rent Property'),
      ),
      body: Center(
        child: Text('Rent Property Screen'),
      ),
    );
  }
}