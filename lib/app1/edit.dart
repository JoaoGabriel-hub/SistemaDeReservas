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

  void _showEditDialog(BuildContext context, Map<String, dynamic> property) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: property['title']);
    final descriptionController = TextEditingController(text: property['description']);
    final maxGuestController = TextEditingController(text: property['max_guest'].toString());
    final priceController = TextEditingController(text: property['price'].toString());
    final numberController = TextEditingController(text: property['number'].toString());
    final complementController = TextEditingController(text: property['complement']);
    final thumbnailController = TextEditingController(text: property['thumbnail']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Propriedade'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: 'Título'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um título válido';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Descrição'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira uma descrição válida';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: maxGuestController,
                    decoration: InputDecoration(labelText: 'Máximo de Hóspedes'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty || int.tryParse(value) == null) {
                        return 'Por favor, insira um número válido';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: 'Preço'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty || double.tryParse(value) == null) {
                        return 'Por favor, insira um preço válido';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: numberController,
                    decoration: InputDecoration(labelText: 'Número'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty || int.tryParse(value) == null) {
                        return 'Por favor, insira um número válido';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: complementController,
                    decoration: InputDecoration(labelText: 'Complemento'),
                  ),
                  TextFormField(
                    controller: thumbnailController,
                    decoration: InputDecoration(labelText: 'URL da Imagem'),
                    validator: (value) {
                      if (value == null || value.isEmpty || !_isValidUrl(value)) {
                        return 'Por favor, insira uma URL válida';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  var db = DataBaseHelper();
                  db.updateProperty(
                    property['id'],
                    titleController.text,
                    descriptionController.text,
                    int.parse(numberController.text),
                    complementController.text,
                    double.parse(priceController.text),
                    int.parse(maxGuestController.text),
                    thumbnailController.text
                    
                  );
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => EditPropertiesScreen()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Todos os campos devem ser preenchidos de forma correta')),
                  );
                }
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edição de Propriedades'),
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
                    onTap: () => _showEditDialog(context, property),
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