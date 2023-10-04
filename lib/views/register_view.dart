import 'package:firstflutternotes/constants/routes.dart';
import 'package:firstflutternotes/services/auth/auth_exceptions.dart';
import 'package:firstflutternotes/services/auth/auth_service.dart';
import 'package:firstflutternotes/utilities/show_error_dialog.dart';
import 'package:flutter/material.dart';



class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(backgroundColor:Colors.blue,title: const Text('Register')),
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
                 await AuthService.firebase().createUser(email: username, password: authPassword);
                 await AuthService.firebase().sendEmailVerification();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                } on WeakPasswordAuthException{
                   // ignore: use_build_context_synchronously
                     await showErrorDialog(context, "Weak Password");
                }on EmailAlreadyInUseAuthException{
                    // ignore: use_build_context_synchronously
                     await showErrorDialog(context, "Email in use");
                }
                on InvalidEmailAuthException{
                  // ignore: use_build_context_synchronously
                     await showErrorDialog(context, "Invalid email");
                }
                on GenericAuthException{
                  // ignore: use_build_context_synchronously
                     await showErrorDialog(context, "Failed to register");
                }
                
                
              },child:const Text("Register")),
              TextButton(onPressed: (){
                  Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
              }, child:const  Text("Already registered? Login here"))
            ],
          ),
    );
}}
