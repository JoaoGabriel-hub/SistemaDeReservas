import 'package:flutter/material.dart';

class Reservations extends StatefulWidget {
  @override
  _ReservationsState createState() => _ReservationsState();
}

class _ReservationsState extends State<Reservations> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservations'),
      ),
      body: Center(
        child: Text('Reservations content goes here'),
      ),
    );
  }
}