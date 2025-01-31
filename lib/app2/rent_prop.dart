import 'package:flutter/material.dart';
import '../logged_user.dart';
import '../data_base.dart';

class RentProperty extends StatefulWidget {
  @override
  _RentPropertyState createState() => _RentPropertyState();
}

class _RentPropertyState extends State<RentProperty> {
  List<dynamic> _properties = []; // Lista para armazenar as propriedades

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  // Função para carregar as propriedades do banco de dados
  Future<void> _loadProperties() async {
    var db = DataBaseHelper();
    try {
      List<dynamic> properties = await db.getAllProperties();
      setState(() {
        _properties = properties;
      });
    } catch (e) {
      print("Erro ao carregar propriedades: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rent Property'),
      ),
      body: Column(
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
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (Route<dynamic> route) => false);
                }
              },
            ),
          ),
          Expanded(
            child: _properties.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _properties.length,
                    itemBuilder: (context, index) {
                      var property = _properties[index];
                      return Card(
                        margin: EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(
                              property['title'],
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    property['description'],
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'UF: ${property['uf'].toString()}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  Text(
                                    'Localidade: ${property['localidade'].toString()}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  Text(
                                    'Bairro: ${property['bairro'].toString()}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  Text(
                                    'Máximo de hóspedes: ${property['max_guest'].toString()}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  Text(
                                    'Preço: \$${property['price'].toString()}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  Text(
                                    'Número: ${property['number'].toString()}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  Text(
                                    'Complemento: ${property['complement'] ?? 'Não possui'}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ) 
                       );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
