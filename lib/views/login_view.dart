import 'package:firstflutternotes/constants/routes.dart';
import 'package:firstflutternotes/services/auth/auth_exceptions.dart';
import 'package:firstflutternotes/services/auth/auth_service.dart';
import 'package:firstflutternotes/utilities/show_error_dialog.dart';
import 'package:flutter/material.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController email;
  late final TextEditingController password;

  @override
  void initState() {
    email=TextEditingController();
    password=TextEditingController();
    super.initState();
  }
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue,title:const Text('Login')),
       body: Column(
            children: [
              TextField(
                controller: email,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter your email here'
                ),
              ),
              TextField(
                controller: password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'Enter your password here'
                ),
              ),
              TextButton(onPressed: ()async{
                final username=email.text;
                final authPassword=password.text;
                try{
                await AuthService.firebase().logIn(email: username, password: authPassword);
                
                final user=AuthService.firebase().currentUser;
                if(user?.isEmailVerified ??false){
                    // ignore: use_build_context_synchronously
                Navigator.of(context).pushNamedAndRemoveUntil(tasksroute, (route) => false,);
                }
                else{
                    // ignore: use_build_context_synchronously
                Navigator.of(context).pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false,);
                }
                
                }on UserNotFoundAuthException{
                    // ignore: use_build_context_synchronously
                    await showErrorDialog(context, "User not found",);
                }on WrongPasswordAuthException{
                    // ignore: use_build_context_synchronously
                    await showErrorDialog(context, "Wrong password",);
                }
                on GenericAuthException{
                    // ignore: use_build_context_synchronously
                    await showErrorDialog(context, "Authentication error",);
                }
                
              },child:const Text("Login")),
              TextButton(onPressed: (){
                Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
              }
              , child: const Text("Not registered yet?Register here"))
            ],
          ),
     );
}
}

