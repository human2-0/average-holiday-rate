import 'package:average_holiday_rate_pay/customs/toast.dart';
import 'package:average_holiday_rate_pay/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late FToast fToast;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState(){
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Email input
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
            ),
            const SizedBox(height: 16),
            // Password input
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 16),

            // Login button
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(authStateNotifierProvider.notifier)
                    .signInWithEmailAndPassword(
                        _emailController.text, _passwordController.text,);
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 16),

            // Divider
            const Divider(
              height: 30,
              thickness: 2,
            ),
            const SizedBox(height: 16),

            // Google Sign-In button
            SignInButton(
              Buttons.Google,
              text: 'Sign up with Google',
              onPressed: () async {
                try {
                  await ref
                      .read(authStateNotifierProvider.notifier)
                      .signInWithGoogle();
                  // Handle successful sign in
                } on FormatException catch (error) {
                  // Handle errors
                  if (mounted) {
                    CustomToast(

                      'Login failed ${error.message}',
                      const Icon(Icons.done_outline_rounded),
                      Colors.red[400]!,
                    ).showCustomToast();
                  }
                }
              },
            ),
            const SizedBox(height: 16),

            // Other sign-in options
            TextButton(
              onPressed: () async {
                await context.push('/signup');
              },
              child: const Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
