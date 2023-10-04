import 'package:firstflutternotes/constants/routes.dart';
import 'package:firstflutternotes/enums/menu_action.dart';
import 'package:firstflutternotes/services/auth/auth_service.dart';
import 'package:firstflutternotes/services/crud/tasks_service.dart';
import 'package:flutter/material.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  String get userEmail=>AuthService.firebase().currentUser!.email!;
  late final TasksService _tasksService;
  @override
  void initState() {
    _tasksService=TasksService();
    super.initState();
  }

  @override
  void dispose() {
    _tasksService.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue,title:const Text('Your Tasks'),
      actions: [
        IconButton(onPressed: (){
            Navigator.of(context).pushNamed(newTasksRoute);
        },
         icon: const Icon(Icons.add)),
        PopupMenuButton<MenuAction>(
          onSelected:(value) async{
            switch (value){
              case MenuAction.logout:final shouldlogout=await showLogOutDialog(context);
              if(shouldlogout){
                await AuthService.firebase().logOut();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_) => false);
              }
              
              break;
               
            }
        } ,itemBuilder: (context){
          return [
            const PopupMenuItem<MenuAction>(
            value:MenuAction.logout
            ,child:Text("Logout"))
          ];
        },)
      ],
      
      ),
      body: FutureBuilder(
        future: _tasksService.getOrCreateUser(email: userEmail),
        builder:(context, snapshot) {
          switch(snapshot.connectionState){
             case ConnectionState.done:
              return StreamBuilder(stream: _tasksService.allTasks, builder: (context, snapshot) {
                switch(snapshot.connectionState){
                  
                 
                  case ConnectionState.waiting:
                    return const Text("Waiting for all tasks...");
                    default:
                    return const CircularProgressIndicator();

                 
                }
                },);
           default:
           return const CircularProgressIndicator();
           
          }
        },)
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context){
  return showDialog<bool>(
    context: context
  , builder: (context) {
    return AlertDialog(
      title: const Text("Sign out"),
      content: const Text("Are you sure you wanna sign out"),
      actions: [
        TextButton(onPressed: (){
          Navigator.of(context).pop(false);
        }, child: const Text("Cancel")),
         TextButton(onPressed: (){
          Navigator.of(context).pop(true);
        }, child: const Text("Logout"))
      ],
      

    );
  },).then((value)=>value ?? false);
}
