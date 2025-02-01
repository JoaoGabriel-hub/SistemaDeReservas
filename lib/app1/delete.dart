import 'package:flutter/material.dart';
import 'package:projetofinal/data_base.dart';

class DeletePropertiesScreen extends StatelessWidget {
  
  Future<List<Map<String, dynamic>>> _fetchProperties() async {
    var db = DataBaseHelper();
    return await db.getUserProperties();
  }

  void _showDeleteConfirmationDialog(BuildContext context, int propertyId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Você tem certeza que deseja excluir esta propriedade?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Excluir'),
              onPressed: () {
                _deleteProperty(context, propertyId);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteProperty(BuildContext context, int propertyId) async {
    var db = DataBaseHelper();
    await db.deleteProperty(propertyId);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Propriedade excluída com sucesso')),
    );
    // Recarregar a lista de propriedades
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => DeletePropertiesScreen()),
    );
  }

  bool _isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remoção de Propriedades'),
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
                    onTap: () {
                      _showDeleteConfirmationDialog(context, property['id']);
                    },
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