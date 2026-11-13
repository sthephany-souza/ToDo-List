class User {
  // Classe que representa a entidade Usuário no sistema
  final String? id; // Identificador único gerado 
  final String name; // Nome completo do usuário
  final String email; // E-mail (usado como login)
  final String password; // Senha do usuário

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  // Converte o objeto User em um Map (JSON) para salvar no MongoDB
  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'email': email,
      'password': password,
    };

    if (id != null) {
      map['id'] = id as dynamic;
    }
    return map;
  }

  // Cria um objeto User a partir de um Map retornado do MongoDB
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }
}