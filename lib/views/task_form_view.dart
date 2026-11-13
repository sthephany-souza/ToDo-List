import 'package:flutter/material.dart';
import '../components/custom_text_field.dart';
import '../models/task.dart';
import '../services/supabase_service.dart';

// Tela do formulário para adicionar ou editar uma Tarefa (CRUD - Create/Update)
class TaskFormView extends StatefulWidget {
  const TaskFormView({super.key});

  @override
  State<TaskFormView> createState() => _TaskFormViewState();
}

class _TaskFormViewState extends State<TaskFormView> {
  // Chave global do formulário
  final _formKey = GlobalKey<FormState>();
  
  // Controladores dos campos de texto
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  // Variável booleana para controlar se a tarefa está concluída
  bool _isCompleted = false;

  String? userId;
  TaskModel? _editingTask;
  bool _isInit = false;

  // Método executado quando os argumentos da rota são recebidos
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      // Recebe os parâmetros passados ao navegar para esta tela
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      userId = args['userId'];
      _editingTask = args['task'];

      // Se passou uma tarefa existente, preenche os campos para Edição
      if (_editingTask != null) {
        _titleController.text = _editingTask!.title;
        _descController.text = _editingTask!.description;
        _isCompleted = _editingTask!.isCompleted;
      }
      _isInit = true;
    }
  }

  // Salva no banco de dados (Cria novo ou Atualiza existente)
  void _save() async {
    if (_formKey.currentState!.validate()) {
      if (_editingTask == null) {
        // --- CRIAR (CREATE) ---
        await SupabaseService.createTask(
          TaskModel(
            userId: userId!,
            title: _titleController.text.trim(),
            description: _descController.text.trim(),
            isCompleted: _isCompleted,
          ),
        );
      } else {
        // --- ATUALIZAR (UPDATE) ---
        await SupabaseService.updateTask(
          TaskModel(
            id: _editingTask!.id,
            userId: userId!,
            title: _titleController.text.trim(),
            description: _descController.text.trim(),
            isCompleted: _isCompleted,
          ),
        );
      }
      
      // Fecha o formulário e retorna para a tela principal (Home)
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Altera o título dinamicamente se estiver editando ou criando
        title: Text(_editingTask == null ? 'Nova Tarefa' : 'Editar Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo Título
              CustomTextField(
                controller: _titleController,
                label: 'Título',
                validator: (val) => val == null || val.isEmpty ? 'Informe o título' : null,
              ),
              const SizedBox(height: 16),
              
              // Campo Descrição
              CustomTextField(
                controller: _descController,
                label: 'Descrição',
                validator: (val) => val == null || val.isEmpty ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 16),
              
              // Checkbox para alternar o status de conclusão da tarefa
              CheckboxListTile(
                title: const Text('Tarefa Concluída'),
                value: _isCompleted,
                onChanged: (bool? value) {
                  setState(() {
                    _isCompleted = value ?? false;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Botão de Ação (Salvar)
              ElevatedButton(
                onPressed: _save,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}