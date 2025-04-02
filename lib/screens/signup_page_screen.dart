import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import 'login_page_screen.dart';
import 'learn_track_dash.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(9, 24, 9, 94),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        // Logo and App Name
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 68,
                            vertical: 13,
                          ),
                          child: Column(
                            children: [
                              Image.network(
                                "https://cdn.builder.io/api/v1/image/assets/TEMP/2490f025ba2e9645b857766be5713dc7da3aae0ef1487df3c082c802301ba379?placeholderIfAbsent=true&apiKey=b7b395ae03b14b728868337a9d3fb267",
                                width: 68,
                                height: 56,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 9),
                              Text(
                                'LearnTrack',
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Form Container
                        Container(
                          margin: const EdgeInsets.only(top: 32),
                          padding: const EdgeInsets.fromLTRB(25, 25, 25, 41),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white.withOpacity(0.8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create Account',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                CustomTextField(
                                  controller: _nameController,
                                  label: 'Full Name',
                                  hintText: 'Enter your name',
                                ),
                                const SizedBox(height: 16),

                                CustomTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  hintText: 'Enter your email',
                                ),
                                const SizedBox(height: 16),

                                CustomTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hintText: 'Create a password',
                                  isPassword: true,
                                ),
                                const SizedBox(height: 16),

                                CustomTextField(
                                  controller: _ageController,
                                  label: 'Age',
                                  hintText: 'Enter your age',
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16),

                                // Create Account Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        final authProvider =
                                            Provider.of<AuthProvider>(context,
                                                listen: false);
                                        try {
                                          await authProvider.signUp(
                                            fullName:
                                                _nameController.text.trim(),
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text,
                                            age: int.parse(
                                                _ageController.text.trim()),
                                          );
                                          if (!mounted) return;

                                          if (authProvider.error == null) {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const LearnTrackDash(),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content:
                                                    Text(authProvider.error!),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString()),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F46E5),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Create Account',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Sign In Link
                        Padding(
                          padding: const EdgeInsets.fromLTRB(64, 24, 64, 3),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Already have an account? ',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: const Color(0xFF4B5563),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Sign In',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF4F46E5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
