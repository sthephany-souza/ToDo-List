class TaskModel {
  // Classe que representa o compromisso agendado
  final String? id; // ID do compromisso
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
    final map = {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'userId': userId,
    };

    // Se o ID existir (ao atualizar), incluímos no mapa para o Supabase saber qual registro alterar
    if (id != null) {
      map['id'] = id as dynamic;
    }
    return map;
  }
  
  // Converte o Map retornado do banco de volta para a classe Appointment
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      userId: map['userId'] ?? '',
    );
  }
}