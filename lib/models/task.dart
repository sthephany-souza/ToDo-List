import 'package:mongo_dart/mongo_dart.dart';

class TaskModel {
  // Classe que representa o compromisso agendado
  final ObjectId? id; // ID do compromisso no MongoDB
  final String userId; // ID do usuário dono desse compromisso (vínculo)
  final String title; // Título do compromisso
  final String description; // Descrição detalhada
  final bool isCompleted; // Marcar como completo

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'userId': userId,
    };
  }
  
  // Converte o Map retornado do banco de volta para a classe Appointment
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['_id'] as ObjectId?,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      userId: map['userId'] ?? '',
    );
  }
}