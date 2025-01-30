import 'package:flutter/material.dart';
import '../logged_user.dart';

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
        child: Column(
            children: [
            Align(
              alignment: Alignment.topRight,
              child: PopupMenuButton<String>(
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Deslogar'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'reservas',
                    child: Text('Minhas reservas'),
                  ),
                ],
                onSelected: (String result) {
                  if (result == 'logout') {
                    LoggedUser().logout();
                    Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}