import 'package:flutter/material.dart';
import 'package:projetofinal/data_base.dart';
import 'package:image_picker/image_picker.dart'; // Importação adicionada
import 'dart:io'; // Importação adicionada
import 'main_manage_prop.dart';

class CreatePropertyScreen extends StatefulWidget { // Alterado para StatefulWidget
  @override
  _CreatePropertyScreenState createState() => _CreatePropertyScreenState();
}

class _CreatePropertyScreenState extends State<CreatePropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxGuestController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _cepController = TextEditingController();
  final List<File?> _imageFiles = [null]; // Lista de arquivos de imagem

  final ImagePicker _picker = ImagePicker(); // Instância do ImagePicker

  void _addImageField() {
    setState(() {
      _imageFiles.add(null);
    });
  }

  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFiles[index] = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Propriedade'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o título';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20), // Espaçamento adicionado
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descrição'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20), // Espaçamento adicionado
              TextFormField(
                controller: _numberController,
                decoration: InputDecoration(labelText: 'Número'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null) {
                    return 'Por favor, insira um número válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20), // Espaçamento adicionado
              TextFormField(
                controller: _complementController,
                decoration: InputDecoration(labelText: 'Complemento'),
                validator: (value) {
                  // Campo opcional, não precisa de validação
                  return null;
                },
              ),
              SizedBox(height: 20), // Espaçamento adicionado
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Preço'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null) {
                    return 'Por favor, insira um preço válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20), // Espaçamento adicionado
              TextFormField(
                controller: _maxGuestController,
                decoration: InputDecoration(labelText: 'Máximo de Convidados'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o máximo de convidados';
                  } else if (int.tryParse(value) == null) {
                    return 'Por favor, insira um número válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20), // Espaçamento adicionado
              TextFormField(
                controller: _thumbnailController,
                decoration: InputDecoration(labelText: 'Thumbnail URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a URL da thumbnail';
                  }
                  return null;
                },
              ),
              
              TextFormField(
                controller: _cepController,
                decoration: InputDecoration(labelText: 'CEP'),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null) {
                    return 'Por favor, insira um CEP válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text('Imagens Adicionais'),
              Column(
                children: _imageFiles.asMap().entries.map((entry) {
                  int index = entry.key;
                  File? file = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        file == null
                            ? Text('Nenhuma imagem selecionada.')
                            : Image.file(file, height: 100),
                        TextButton(
                          onPressed: () => _pickImage(index),
                          child: Text('Selecionar Imagem'),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              TextButton(
                onPressed: _addImageField,
                child: Text('Adicionar Imagem'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    var db = DataBaseHelper();
                    await db.insertProperty(
                      _titleController.text,
                      _descriptionController.text,
                      int.parse(_numberController.text),
                      _complementController.text,
                      double.parse(_priceController.text),
                      int.parse(_maxGuestController.text),
                      _thumbnailController.text,
                      _cepController.text,
                      _imageFiles.where((file) => file != null).map((file) => file!.path).toList(),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ManageProperty()),
                    );
                  }
                },
                child: Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
