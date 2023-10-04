import 'package:firstflutternotes/constants/routes.dart';
import 'package:firstflutternotes/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue,title:const Text("Email Verification")),
      body: Column(children: [
        const Text("We've sent you an email verification. PLease open in to verify your account."),
        const Text("If you haven't received it yet , press the button below "),
            TextButton(onPressed: ()async{
              
              await AuthService.firebase().sendEmailVerification();
            }, child: const Text ('Send email verification')
            ),
            TextButton(onPressed: () async
            {
              await AuthService.firebase().logOut();
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
             child: const Text("Restart")),
          ],),
    );
  }
}
