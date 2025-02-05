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
  final TextEditingController _checkinController = TextEditingController();
  final TextEditingController _checkoutController = TextEditingController();

  bool _showFilters = false;
  bool _filterUF = false;
  bool _filterBairro = false;
  bool _filterCidade = false;
  bool _filterMaxGuests = false;
  bool _filterDates = false;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    var db = DataBaseHelper();
    try {
      List<dynamic> properties = await db.getAllProperties();
      List<Map<String, dynamic>> mutableProperties = properties.map((p) => Map<String, dynamic>.from(p)).toList();
      for (var property in mutableProperties) {
        property['rating'] = await db.calculateRating(property['id']);
      }
      mutableProperties.sort((a, b) => b['rating'].compareTo(a['rating']));
      setState(() {
        _properties = mutableProperties;
        _filteredProperties = mutableProperties;
      });
    } catch (e) {
      print("Erro ao carregar propriedades: \$e");
    }
  }


  Future<void> _filterProperties() async {
    var db = DataBaseHelper();
    String uf = _ufController.text.trim().toLowerCase();
    String bairro = _bairroController.text.trim().toLowerCase();
    String cidade = _cidadeController.text.trim().toLowerCase();
    int? maxGuests = int.tryParse(_maxGuestController.text.trim());
    String checkin = _checkinController.text.trim();
    String checkout = _checkoutController.text.trim();

    List<dynamic> filtered = _properties.where((property) {
      bool matchesUF = !_filterUF || uf.isEmpty || property['uf'].toString().toLowerCase().contains(uf);
      bool matchesBairro = !_filterBairro || bairro.isEmpty || property['bairro'].toString().toLowerCase().contains(bairro);
      bool matchesCidade = !_filterCidade || cidade.isEmpty || property['localidade'].toString().toLowerCase().contains(cidade);
      bool matchesMaxGuests = !_filterMaxGuests || maxGuests == null || property['max_guest'] >= maxGuests;
      return matchesUF && matchesBairro && matchesCidade && matchesMaxGuests;
    }).toList();

    if (_filterDates && checkin.isNotEmpty && checkout.isNotEmpty) {
      filtered = await db.getAvailableProperties(checkin, checkout, filtered);
    }

    setState(() {
      _filteredProperties = filtered;
    });
  }

  bool _isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
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
                } else if (result == 'reservas') {
                  Navigator.pushNamed(context, '/reservations');
                }
                },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
              child: Text(_showFilters ? 'Ocultar Filtros' : 'Buscar por'),
            ),
          ),
          if (_showFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: Text('Buscar por UF'),
                    value: _filterUF,
                    onChanged: (value) {
                      setState(() => _filterUF = value!);
                    },
                  ),
                  if (_filterUF)
                    TextField(
                      controller: _ufController,
                      decoration: InputDecoration(labelText: 'Digite a UF'),
                      onChanged: (value) => _filterProperties(),
                    ),
                  CheckboxListTile(
                    title: Text('Buscar por Bairro'),
                    value: _filterBairro,
                    onChanged: (value) {
                      setState(() => _filterBairro = value!);
                    },
                  ),
                  if (_filterBairro)
                    TextField(
                      controller: _bairroController,
                      decoration: InputDecoration(labelText: 'Digite o Bairro'),
                      onChanged: (value) => _filterProperties(),
                    ),
                  CheckboxListTile(
                    title: Text('Buscar por Cidade'),
                    value: _filterCidade,
                    onChanged: (value) {
                      setState(() => _filterCidade = value!);
                    },
                  ),
                  if (_filterCidade)
                    TextField(
                      controller: _cidadeController,
                      decoration: InputDecoration(labelText: 'Digite a Cidade'),
                      onChanged: (value) => _filterProperties(),
                    ),
                  CheckboxListTile(
                    title: Text('Máximo de Hóspedes'),
                    value: _filterMaxGuests,
                    onChanged: (value) {
                      setState(() => _filterMaxGuests = value!);
                    },
                  ),
                  if (_filterMaxGuests)
                    TextField(
                      controller: _maxGuestController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Digite o máximo de hóspedes'),
                      onChanged: (value) => _filterProperties(),
                    ),
                  CheckboxListTile(
                    title: Text('Buscar por Data de Check-in e Check-out'),
                    value: _filterDates,
                    onChanged: (value) {
                      setState(() => _filterDates = value!);
                    },
                  ),
                  if (_filterDates) ...[
                    TextField(
                      controller: _checkinController,
                      decoration: InputDecoration(labelText: 'Data de Check-in (YYYY-MM-DD)'),
                    ),
                    TextField(
                      controller: _checkoutController,
                      decoration: InputDecoration(labelText: 'Data de Check-out (YYYY-MM-DD)'),
                    ),
                  ],
                  ElevatedButton(
                    onPressed: _filterProperties,
                    child: Text('Aplicar Filtros'),
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
                                  Text('Avaliação média: ${property['rating'].toStringAsFixed(1)}', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Máximo de hóspedes: ${property['max_guest']}', style: TextStyle(color: Colors.grey[600])),
                                  Text('Preço por diária: \$${property['price']}', style: TextStyle(color: Colors.grey[600])),
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
