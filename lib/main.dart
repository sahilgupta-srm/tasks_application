
import 'package:firstflutternotes/constants/routes.dart';
import 'package:firstflutternotes/services/auth/auth_service.dart';
import 'package:firstflutternotes/views/login_view.dart';
import 'package:firstflutternotes/views/tasks/new_tasks_view.dart';
import 'package:firstflutternotes/views/tasks/tasks_view.dart';
import 'package:firstflutternotes/views/register_view.dart';
import 'package:firstflutternotes/views/verify_email.dart';
import 'package:flutter/material.dart';




void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        loginRoute:(context)=>const LoginView(),
        registerRoute:(context)=> const RegisterView(),
        tasksroute:(context) => const TasksView(),
        verifyEmailRoute:(context) => const VerifyEmailView(),
        newTasksRoute:(context)=>const NewTasksView(),
      },
    ));
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  FutureBuilder(
        future:AuthService.firebase().initialize(),
        builder:(context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.done:
           final user=AuthService.firebase().currentUser;
            if( user!=null){
              if( user.isEmailVerified){
                return const TasksView();
              }
              else{
                return const VerifyEmailView();
              }
            }
            else{
              return const LoginView();
            }
            
            
             
            default:
            return const CircularProgressIndicator();
          }
        },
        
      );
  }

  
  
}




