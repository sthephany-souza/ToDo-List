import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/task.dart';
import '../models/user.dart' as model;

class SupabaseService {
  // Transformei em static para poder ser usado nos métodos estáticos abaixo
  static final _supabase = Supabase.instance.client;

  // Nome das tabelas (usei minúsculo conforme o print anterior)
  static const String USER_TABLE = "user";
  static const String TASK_TABLE = "task";

  // --- AUTENTICAÇÃO ---

  static Future<bool> registerUser(model.User user) async {
    try {
      final response = await _supabase.auth.signUp(
        email: user.email,
        password: user.password,
      );

      print('USER ID: ${response.user?.id}');
      print('SESSION: ${response.session != null}');
      
      if (response.user != null) {
        await _supabase.from(USER_TABLE).insert({
          'id': response.user!.id,
          'name': user.name,
          'email': user.email.trim(),
        });
        return true;
      }
      return false;
    } on AuthException catch (e) {
      print('ERRO DE AUTENTICAÇÃO: ${e.message}');
      print('STATUS CODE: ${e.statusCode}');
      return false;
    } catch (e) {
      print('ERRO INESPERADO: $e');
      return false;
    }
  }

  // Realiza o login usando a Auth do Supabase
  static Future<model.User?> loginUser(String email, String password) async {
    try {
      // Faz o login
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // Busca os dados adicionais desse usuário na tabela 'user'
        final userData = await _supabase
            .from(USER_TABLE)
            .select()
            .eq('id', response.user!.id)
            .maybeSingle(); // maybeSingle() retorna 1 registro ou nulo

        if (userData != null) {
          return model.User.fromMap(userData);
        }
      }
      return null;
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }

  // --- CRUD DE COMPROMISSOS (TASKS) ---

  // READ (Ler): Busca apenas os compromissos pertencentes ao usuário logado
  static Future<List<TaskModel>> getTasks(String userId) async {
    // .select() substitui o .find() do Mongo
    final response = await _supabase
        .from(TASK_TABLE)
        .select()
        .eq('userId', userId); // eq substitui o where.eq() do Mongo

    return (response as List).map((map) => TaskModel.fromMap(map)).toList();
  }

  // CREATE (Criar): Salva um novo compromisso no banco
  static Future<void> createTask(TaskModel task) async {
    // .insert() substitui o .insertOne() do Supabase
    await _supabase.from(TASK_TABLE).insert(task.toMap());
  }

  // UPDATE (Atualizar): Atualiza os dados de um compromisso por seu ID
  static Future<void> updateTask(TaskModel task) async {
    // .update() substitui o .replaceOne()
    await _supabase
        .from(TASK_TABLE)
        .update(task.toMap())
        .eq('id', task.id!);
  }

  // DELETE (Deletar): Remove um compromisso do banco pelo ID
  // Atenção: Aqui o ObjectId mudou para String
  static Future<void> deleteTask(String id) async {
    // .delete() substitui o .remove()
    await _supabase
        .from(TASK_TABLE)
        .delete()
        .eq('id', id);
  }
}