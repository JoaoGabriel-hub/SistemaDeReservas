import 'package:flutter/material.dart';
import '../logged_user.dart';
import '../data_base.dart';

class RentProperty extends StatefulWidget {
  @override
  _RentPropertyState createState() => _RentPropertyState();
}

class _RentPropertyState extends State<RentProperty> {
  List<dynamic> _properties = [];
  List<dynamic> _filteredProperties = [];
  final TextEditingController _ufController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _maxGuestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    var db = DataBaseHelper();
    try {
      List<dynamic> properties = await db.getAllProperties();
      setState(() {
        _properties = properties;
        _filteredProperties = properties;
      });
    } catch (e) {
      print("Erro ao carregar propriedades: $e");
    }
  }

  bool _isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  void _filterProperties() {
    String uf = _ufController.text.trim().toLowerCase();
    String bairro = _bairroController.text.trim().toLowerCase();
    String cidade = _cidadeController.text.trim().toLowerCase();
    int? maxGuests = int.tryParse(_maxGuestController.text.trim());

    setState(() {
      _filteredProperties = _properties.where((property) {
        bool matchesUF = uf.isEmpty || property['uf'].toString().toLowerCase().contains(uf);
        bool matchesBairro = bairro.isEmpty || property['bairro'].toString().toLowerCase().contains(bairro);
        bool matchesCidade = cidade.isEmpty || property['localidade'].toString().toLowerCase().contains(cidade);
        bool matchesMaxGuests = maxGuests == null || property['max_guest'] >= maxGuests;

        return matchesUF && matchesBairro && matchesCidade && matchesMaxGuests;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rent Property')),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: PopupMenuButton<String>(
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(value: 'logout', child: Text('Deslogar')),
                const PopupMenuItem<String>(value: 'reservas', child: Text('Minhas reservas')),
              ],
              onSelected: (String result) {
                if (result == 'logout') {
                  LoggedUser().logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
                }
              },
            ),
          ),

          // Campos de busca
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: [
                TextField(
                  controller: _ufController,
                  decoration: InputDecoration(labelText: 'Buscar por UF'),
                  onChanged: (value) => _filterProperties(),
                ),
                TextField(
                  controller: _bairroController,
                  decoration: InputDecoration(labelText: 'Buscar por Bairro'),
                  onChanged: (value) => _filterProperties(),
                ),
                TextField(
                  controller: _cidadeController,
                  decoration: InputDecoration(labelText: 'Buscar por Cidade'),
                  onChanged: (value) => _filterProperties(),
                ),
                TextField(
                  controller: _maxGuestController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Máximo de Hóspedes'),
                  onChanged: (value) => _filterProperties(),
                ),
              ],
            ),
          ),

          Expanded(
            child: _filteredProperties.isEmpty
                ? Center(child: Text('Nenhuma propriedade encontrada'))
                : ListView.builder(
                    itemCount: _filteredProperties.length,
                    itemBuilder: (context, index) {
                      var property = _filteredProperties[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: Card(
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
                                  Text(property['description'], style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 8),
                                  Text('UF: ${property['uf']}', style: TextStyle(color: Colors.grey[600])),
                                  Text('Localidade: ${property['localidade']}', style: TextStyle(color: Colors.grey[600])),
                                  Text('Bairro: ${property['bairro']}', style: TextStyle(color: Colors.grey[600])),
                                  Text('Máximo de hóspedes: ${property['max_guest']}', style: TextStyle(color: Colors.grey[600])),
                                  Text('Preço: \$${property['price']}', style: TextStyle(color: Colors.grey[600])),
                                  Text('Número: ${property['number']}', style: TextStyle(color: Colors.grey[600])),
                                  Text('Complemento: ${property['complement'] ?? 'Não possui'}', style: TextStyle(color: Colors.grey[600])),
                                  if (_isValidUrl(property['thumbnail']))
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Image.network(
                                        property['thumbnail'],
                                        width: 200,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/each_prop',
                                arguments: property,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
