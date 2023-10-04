import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NewTasksView extends StatefulWidget {
  const NewTasksView({super.key});

  @override
  State<NewTasksView> createState() => _NewTasksViewState();
}

class _NewTasksViewState extends State<NewTasksView> {
  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      appBar:AppBar(backgroundColor: Colors.blue,title:const Text("New Task")) ,
      body: const Text("Write you new Task here..."),
      );
  }
}
