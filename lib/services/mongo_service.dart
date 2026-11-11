import 'package:mongo_dart/mongo_dart.dart';

import '../models/task.dart';
import '../models/user.dart';

class MongoService {
  // String de conexão com o MongoDB Atlas ou Local
  static const String MONGO_URL = "mongodb+srv://sthephy030_db_user:c89rYvPySw9rWh2z@cluster0.3y1hdm1.mongodb.net/";
  
  // Nome das coleções (tabelas no NoSQL)
  static const String USER_COLLECTION = "users";
  static const String Task_COLLECTION = "Tasks";

  static late Db db; // Instância estática do banco de dados

  // Inicializa a conexão com o MongoDB
  static Future<void> connect() async {
    db = await Db.create(MONGO_URL);
    await db.open(); // Abre o socket de conexão
  }

  // --- AUTENTICAÇÃO ---

  // Cadastra um novo usuário caso o e-mail não exista
  static Future<bool> registerUser(User user) async {
    final collection = db.collection(USER_COLLECTION);
    // Verifica se já existe um usuário com esse e-mail no banco
    final existingUser = await collection.findOne(where.eq('email', user.email));
    
    if (existingUser != null) {
      return false; // Retorna falso se o e-mail já estiver cadastrado
    }

    await collection.insertOne(user.toMap()); // Insere a foto do documento
    return true;
  }

  // Realiza o login comparando e-mail e senha
  static Future<User?> loginUser(String email, String password) async {
    final collection = db.collection(USER_COLLECTION);
    // Busca um registro que combine e-mail E senha
    final userData = await collection.findOne(
      where.eq('email', email).eq('password', password),
    );
    
    if (userData == null) return null; // Retorna null se não achar nada
    return User.fromMap(userData); // Retorna a instância do usuário logado
  }

  // --- CRUD DE COMPROMISSOS ---

  // READ (Ler): Busca apenas os compromissos pertencentes ao usuário logado
  static Future<List<TaskModel>> getTasks(String userId) async {
    final collection = db.collection(Task_COLLECTION);
    final list = await collection.find(where.eq('userId', userId)).toList();
    return list.map((map) => TaskModel.fromMap(map)).toList();
  }

  // CREATE (Criar): Salva um novo compromisso no banco
  static Future<void> createTask(TaskModel task) async {
    final collection = db.collection(Task_COLLECTION);
    await collection.insertOne(task.toMap());
  }

  // UPDATE (Atualizar): Atualiza os dados de um compromisso por seu ID
  static Future<void> updateTask(TaskModel task) async {
    final collection = db.collection(Task_COLLECTION);
    await collection.replaceOne(where.id(task.id!), task.toMap());
  }

  // DELETE (Deletar): Remove um compromisso do banco pelo ID
  static Future<void> deleteTask(ObjectId id) async {
    final collection = db.collection(Task_COLLECTION);
    await collection.remove(where.id(id));
  }
}