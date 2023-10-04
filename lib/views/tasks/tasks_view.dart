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
  Widget build(BuildContext context)  {
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
               await TasksService().getAllTasks();
            
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
                  case ConnectionState.active:
                    if(snapshot.hasData){
                      final allTasks=snapshot.data as List<DataBaseTasks>;
                      return ListView.builder(
                        itemCount: allTasks.length,
                        itemBuilder: (context, index) {
                          final show=allTasks[index];
                          return ListTile(
                            title:Text(
                              show.text,
                              maxLines: 1,
                              softWrap:true ,
                              overflow: TextOverflow.ellipsis,
                            )
                          ); 
                          
                          
                        },);
                    }
                    else{
                      return const CircularProgressIndicator();
                    }
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
