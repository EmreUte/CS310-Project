import 'package:flutter/material.dart';
import 'login_page.dart';
import 'create_user_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Top-left car
            Positioned(
              top: 40,
              left: 10,
              child: Image.asset(
                'assets/car.png', // Make sure car.png is in assets folder
                width: 100,
              ),
            ),
            // Top-right car
            Positioned(
              top: 40,
              right: 10,
              child: Image.asset(
                'assets/car.png',
                width: 100,
              ),
            ),
            // Bottom-left car
            Positioned(
              bottom: 40,
              left: 10,
              child: Image.asset(
                'assets/car.png',
                width: 100,
              ),
            ),
            // Bottom-right car
            Positioned(
              bottom: 40,
              right: 10,
              child: Image.asset(
                'assets/car.png',
                width: 100,
              ),
            ),

            // Center content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'WELCOME TO MYRIDE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Login button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      backgroundColor: Color(0xFF5E548E), // Purple color
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),


                  const Text(
                    "Don't Have an Account?",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign Up button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistrationPage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      side: const BorderSide(color: Color(0xFF5E548E)),
                    ),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF5E548E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
