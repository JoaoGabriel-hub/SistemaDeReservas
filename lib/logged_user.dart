class LoggedUser { //Classe que armazena o usuário logado
  static final LoggedUser _instance = LoggedUser._internal();
  int? id;

  factory LoggedUser() {
    return _instance;
  }

  LoggedUser._internal();

  void setUser(int userId) {
    id = userId;
  }
}