import 'package:firstflutternotes/services/auth/auth_service.dart';
import 'package:firstflutternotes/services/crud/tasks_service.dart';
import 'package:flutter/material.dart';

class NewTasksView extends StatefulWidget {
  const NewTasksView({super.key});

  @override
  State<NewTasksView> createState() => _NewTasksViewState();
}

class _NewTasksViewState extends State<NewTasksView> {
  DataBaseTasks? _task;
  late final TasksService _tasksService;
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _tasksService = TasksService();
    _textEditingController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final task = _task;
    if (task == null) {
      return;
    }
    final text = _textEditingController.text;
    await _tasksService.updateTasks(task: task, text: text);
  }

  void _setupTextControllerListener() {
    _textEditingController.removeListener(_textControllerListener);
    _textEditingController.addListener(_textControllerListener);
  }

  Future<DataBaseTasks> createNewTask() async {
    final existingtask=_task;
    if(existingtask!=null){
      return existingtask;
    }
    final currentUser=AuthService.firebase().currentUser!;
    
    final email=currentUser.email!;
    final owner=await _tasksService.getUser(email: email);
    final a= await _tasksService.createTask(owner: owner);
    
    return a;
  }

  void _deleteTaskIfTextIsEmpty() {
    final task = _task;
    if (_textEditingController.text.isEmpty && task != null) {
      _tasksService.deleteTask(id: task.id);
    }
  }

  void _saveTaskIfTextNotEmpty() async {
    final task = _task;
    final text = _textEditingController.text;
    if (task != null && text.isNotEmpty) {
    await _tasksService.updateTasks(task: task, text: text);

    }
  }

  @override
  void dispose() {
    _deleteTaskIfTextIsEmpty();
    _saveTaskIfTextNotEmpty();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue, title: const Text("New Task")),
      body: FutureBuilder(
        future: createNewTask(),
       builder: (context, snapshot) {
  switch (snapshot.connectionState) {
    case ConnectionState.done:
      final task = snapshot.data as DataBaseTasks?;
      if (task != null) {
        _task = task;
        _setupTextControllerListener();
      }
      return TextField(
        controller: _textEditingController,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        decoration: const InputDecoration(
          hintText: 'Start typing your task here ...',
                ),
              );

            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

