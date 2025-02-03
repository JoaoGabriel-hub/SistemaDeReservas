import 'package:flutter/material.dart';

class EachProperty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtém os argumentos passados pelo Navigator
    final Map<String, dynamic>? property =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (property == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Detalhes da Propriedade")),
        body: Center(child: Text("Nenhuma propriedade selecionada")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(property['title'] ?? 'Detalhes da Propriedade')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Nome: ${property['title']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Localização: ${property['localidade']}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Preço: \$${property['price']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Máximo de hóspedes: ${property['max_guest']}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'UF: ${property['uf']}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Bairro: ${property['bairro']}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Número: ${property['number']}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Complemento: ${property['complement'] ?? 'Não possui'}',
              style: TextStyle(fontSize: 16),
            ),
            if (property['thumbnail'] != null && Uri.tryParse(property['thumbnail'])?.isAbsolute == true)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Image.network(
                  property['thumbnail'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
