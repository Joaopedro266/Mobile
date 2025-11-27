import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text("Erro",
            style: TextStyle(color: Colors.redAccent, fontFamily: 'Pixelate')),
        content: Text(message,
            style:
                const TextStyle(color: Colors.white, fontFamily: 'Pixelate')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK",
                style: TextStyle(
                    color: Colors.greenAccent, fontFamily: 'Pixelate')),
          ),
        ],
      ),
    );
  }

  void signUserUp() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
            child: CircularProgressIndicator(color: Colors.greenAccent)));

    try {
      if (passwordController.text != confirmPasswordController.text) {
        if (mounted) Navigator.pop(context);
        showAlert("Senhas não conferem!");
        return;
      }

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userNameController.text,
        password: passwordController.text,
      );

      if (mounted) Navigator.pop(context);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context);

      if (e.code == 'email-already-in-use') {
        showAlert("Já existe um usuário com esse email!");
      } else if (e.code == 'weak-password') {
        showAlert("A senha é muito fraca.");
      } else {
        showAlert(e.code.replaceAll('-', ' ').toUpperCase());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.rocket_launch,
                    size: 100, color: Colors.greenAccent),
                const SizedBox(height: 50),
                const Text(
                  'CRIE SEU CADASTRO!',
                  style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 18,
                      fontFamily: 'Pixelate'),
                ),
                const SizedBox(height: 25),
                MyTextField(
                    controller: userNameController,
                    hintText: 'Email',
                    obscureText: false),
                const SizedBox(height: 15),
                MyTextField(
                    controller: passwordController,
                    hintText: 'Senha',
                    obscureText: true),
                const SizedBox(height: 15),
                MyTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirmar Senha',
                    obscureText: true),
                const SizedBox(height: 25),
                MyButton(onTap: signUserUp, text: "REGISTRAR"),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Já tem uma conta?',
                        style: TextStyle(
                            color: Colors.white70, fontFamily: 'Pixelate')),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()));
                      },
                      child: const Text(
                        'Fazer Login',
                        style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Pixelate'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
