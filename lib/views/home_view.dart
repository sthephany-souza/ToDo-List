import 'package:flutter/material.dart';

import '../services/supabase_service.dart';

import '../core/routes.dart';
import '../models/task.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late String userId;
  bool _isInit = false;

  // Variáveis para controlar a Busca e o Filtro
  String _searchQuery = '';
  String _selectedFilter = 'Todas'; // Opções: 'Todas', 'Pendentes', 'Concluídas'

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      userId = ModalRoute.of(context)!.settings.arguments as String;
      _isInit = true;
    }
  }

  // Função para deletar uma tarefa do banco
  void _deleteTask(TaskModel item) async {
    await SupabaseService.deleteTask(item.id!);
    setState(() {}); // Recarrega a tela para atualizar a lista
  }

  // Função para alternar rapidamente o status de concluído direto na lista
  void _toggleTaskCompletion(TaskModel item) async {
    final updatedTask = TaskModel(
      id: item.id,
      userId: item.userId,
      title: item.title,
      description: item.description,
      isCompleted: !item.isCompleted, // Inverte o valor atual
    );
    await SupabaseService.updateTask(updatedTask);
    setState(() {}); // Recarrega a tela
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        actions: [
          // Botão de Logout: Redireciona de volta para a tela de Login
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, Routes.login),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- BARRA DE BUSCA E FILTROS NO TOPO ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Campo de Texto para Pesquisa
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Pesquisar tarefa...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 8),
                
                // Filtros (Todas, Pendentes, Concluídas) usando ChoiceChip
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Todas'),
                      selected: _selectedFilter == 'Todas',
                      onSelected: (selected) {
                        setState(() => _selectedFilter = 'Todas');
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Pendentes'),
                      selected: _selectedFilter == 'Pendentes',
                      onSelected: (selected) {
                        setState(() => _selectedFilter = 'Pendentes');
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Concluídas'),
                      selected: _selectedFilter == 'Concluídas',
                      onSelected: (selected) {
                        setState(() => _selectedFilter = 'Concluídas');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- LISTA DE TAREFAS (FUTURE BUILDER) ---
          Expanded(
            child: FutureBuilder<List<TaskModel>>(
              future: SupabaseService.getTasks(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhuma tarefa cadastrada.'));
                }

                // 1. Pega todas as tarefas do banco
                List<TaskModel> tasks = snapshot.data!;

                // 2. Aplica o Filtro de Status (Todas / Pendentes / Concluídas)
                if (_selectedFilter == 'Pendentes') {
                  tasks = tasks.where((t) => !t.isCompleted).toList();
                } else if (_selectedFilter == 'Concluídas') {
                  tasks = tasks.where((t) => t.isCompleted).toList();
                }

                // 3. Aplica o Filtro de Busca por Texto (Título ou Descrição)
                if (_searchQuery.isNotEmpty) {
                  tasks = tasks.where((t) {
                    final titleMatch = t.title.toLowerCase().contains(_searchQuery);
                    final descMatch = t.description.toLowerCase().contains(_searchQuery);
                    return titleMatch || descMatch;
                  }).toList();
                }

                if (tasks.isEmpty) {
                  return const Center(child: Text('Nenhuma tarefa encontrada com esses critérios.'));
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final item = tasks[index];
                    return ListTile(
                      leading: Checkbox(
                        value: item.isCompleted,
                        onChanged: (bool? value) {
                          _toggleTaskCompletion(item);
                        },
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                          color: item.isCompleted ? Colors.grey : Colors.black,
                        ),
                      ),
                      subtitle: Text(item.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                Routes.taskForm,
                                arguments: {'userId': userId, 'task': item},
                              );
                              setState(() {});
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(item),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Botão Flutuante para ADICIONAR nova tarefa
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(
            context,
            Routes.taskForm,
            arguments: {'userId': userId},
          );
          setState(() {}); 
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}