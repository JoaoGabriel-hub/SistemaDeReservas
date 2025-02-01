import 'package:flutter/material.dart';
import 'package:projetofinal/data_base.dart';

class EditPropertiesScreen extends StatelessWidget {
  
  Future<List<Map<String, dynamic>>> _fetchProperties() async {
    var db = DataBaseHelper();
    return await db.getUserProperties();
  }

  bool _isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Propriedades'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProperties(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar propriedades'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma propriedade encontrada'));
          } else {
            final properties = snapshot.data!;
            return ListView.builder(
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                          if (_isValidUrl(property['thumbnail']))
                            Image.network(
                              property['thumbnail'],
                              width: 200,
                              height: 150,
                              fit: BoxFit.cover,
                            )
                        ],
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    tileColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }


}