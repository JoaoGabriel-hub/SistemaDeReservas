import 'package:flutter/material.dart';
import 'package:projetofinal/logged_user.dart';
import 'create_user.dart';
import 'data_base.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _validateLogin() async {
  try {
    var db = DataBaseHelper();
    final username = _usernameController.text;
    final password = _passwordController.text;

    final user = await db.checkCredentials(username, password);
    
    if (!mounted) return;

    if (user != null) {
      int userId = user['id'];
      LoggedUser().setUser(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login realizado com sucesso')),
      );
      Navigator.pushNamed(context, '/intermed');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário ou senha inválidos')),
      );
    }
  } catch (e) {
    // Log e exiba uma mensagem amigável
    print("Erro ao validar login: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao processar o login. Tente novamente.')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _validateLogin();
                  }
                  if (/*Criar o validador no banco*/ true) {}
                },
                child: Text('Login'),
              ),
               SizedBox(height: 10), 
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateUserScreen()),
                  );
                },
                child: Text('Create Account'),
              ),
               SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/rent_prop');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logado sem cadastro')),
                  );
                },
                child: Text('Logar sem cadastro'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
