import 'package:flutter/material.dart';
import 'package:projetofinal/data_base.dart';
import 'package:intl/intl.dart';
import 'package:projetofinal/logged_user.dart';

class EachProperty extends StatefulWidget {
  @override
  _EachPropertyState createState() => _EachPropertyState();
}

class _EachPropertyState extends State<EachProperty> {
  Map<String, dynamic>? property;
  final DataBaseHelper _dbHelper = DataBaseHelper();
  DateTime? _checkinDate;
  DateTime? _checkoutDate;
  int _guests = 1;
  bool _showForm = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    property ??= ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  }

  Future<void> _selectDate(BuildContext context, bool isCheckin) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now();
    DateTime lastDate = DateTime.now().add(Duration(days: 365));
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (pickedDate != null) {
      setState(() {
        if (isCheckin) {
          _checkinDate = pickedDate;
          if (_checkoutDate != null && _checkoutDate!.isBefore(_checkinDate!)) {
            _checkoutDate = null;
          }
        } else {
          _checkoutDate = pickedDate;
        }
      });
    }
  }

  void _toggleForm() {
    setState(() {
      _showForm = true;
    });
  }

  void _bookProperty() async {
    if (property == null || _checkinDate == null || _checkoutDate == null) return;
    int propertyId = property!['id'];
    String checkinDate = DateFormat('yyyy-MM-dd').format(_checkinDate!);
    String checkoutDate = DateFormat('yyyy-MM-dd').format(_checkoutDate!);

    int? userId = LoggedUser().id;
    bool hasConflict = await _dbHelper.checkUserBookingConflict(userId!, checkinDate, checkoutDate);

    if (hasConflict) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Você já possui uma reserva nesse período.")),
      );
      return;
    }

    bool success = await _dbHelper.insertBooking(propertyId, checkinDate, checkoutDate, _guests);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Reserva realizada com sucesso!" : "Falha ao realizar a reserva. Escolha outras datas.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (property == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Detalhes da Propriedade")),
        body: Center(child: Text("Nenhuma propriedade selecionada")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(property!['title'] ?? 'Detalhes da Propriedade')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Nome: ${property!['title']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Localização: ${property!['localidade']}', style: TextStyle(fontSize: 16)),
            Text('Preço: \$${property!['price']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            
            if (_showForm) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Check-in: ${_checkinDate != null ? DateFormat('dd/MM/yyyy').format(_checkinDate!) : "Selecionar"}'),
                  ElevatedButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text("Selecionar"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Check-out: ${_checkoutDate != null ? DateFormat('dd/MM/yyyy').format(_checkoutDate!) : "Selecionar"}'),
                  ElevatedButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text("Selecionar"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hóspedes: $_guests'),
                  DropdownButton<int>(
                    value: _guests,
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _guests = newValue;
                        });
                      }
                    },
                    items: List.generate(
                      property!['max_guest'],
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text("${index + 1}"),
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: _bookProperty,
                  child: Text('Reservar'),
                ),
              ),
            ] else ...[
              Center(
                child: ElevatedButton(
                  onPressed: _toggleForm,
                  child: Text('Reservar'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
