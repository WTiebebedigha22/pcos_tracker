import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pcos_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_textfield.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController firstNameController = TextEditingController();

  final TextEditingController lastNameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController dobController = TextEditingController();

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  Future<void> selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      dobController.text =
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    dobController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF4FB), Color(0xFFF4F0FF), Color(0xFFEAF4FF)],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 10),

                // BACK BUTTON
                IconButton(
                  onPressed: () {
                    context.pop();
                  },

                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 10),

                // LOGO
                Center(
                  child: Container(
                    height: 88,
                    width: 88,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.pink],
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.25),

                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                // HEADING
                const Center(
                  child: Column(
                    children: [
                      Text(
                        'Create Account ✨',

                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,

                          color: AppColors.textPrimary,
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        'Start tracking your wellness and cycle journey',

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,

                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // FORM CARD
                Container(
                  padding: const EdgeInsets.all(24),

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),

                    borderRadius: BorderRadius.circular(30),

                    border: Border.all(color: Colors.white.withOpacity(0.6)),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),

                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // FIRST NAME
                      const Text(
                        'First Name',

                        style: TextStyle(
                          fontWeight: FontWeight.w600,

                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      CustomTextField(
                        controller: firstNameController,

                        hintText: 'Enter first name',
                      ),

                      const SizedBox(height: 22),

                      // LAST NAME
                      const Text(
                        'Last Name',

                        style: TextStyle(
                          fontWeight: FontWeight.w600,

                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      CustomTextField(
                        controller: lastNameController,

                        hintText: 'Enter last name',
                      ),

                      const SizedBox(height: 22),

                      // EMAIL
                      const Text(
                        'Email Address',

                        style: TextStyle(
                          fontWeight: FontWeight.w600,

                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      CustomTextField(
                        controller: emailController,

                        hintText: 'Enter your email',

                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 22),

                      // DATE OF BIRTH
                      const Text(
                        'Date of Birth',

                        style: TextStyle(
                          fontWeight: FontWeight.w600,

                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextFormField(
                        controller: dobController,

                        readOnly: true,

                        onTap: selectDate,

                        decoration: InputDecoration(
                          hintText: 'Select date of birth',

                          suffixIcon: const Icon(Icons.calendar_month_rounded),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // USERNAME
                      const Text(
                        'Username',

                        style: TextStyle(
                          fontWeight: FontWeight.w600,

                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      CustomTextField(
                        controller: usernameController,

                        hintText: 'Choose username',
                      ),

                      const SizedBox(height: 22),

                      // PASSWORD
                      const Text(
                        'Password',

                        style: TextStyle(
                          fontWeight: FontWeight.w600,

                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextFormField(
                        controller: passwordController,

                        obscureText: obscurePassword,

                        decoration: InputDecoration(
                          hintText: 'Create password',

                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },

                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,

                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // CONFIRM PASSWORD
                      const Text(
                        'Confirm Password',

                        style: TextStyle(
                          fontWeight: FontWeight.w600,

                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextFormField(
                        controller: confirmPasswordController,

                        obscureText: obscureConfirmPassword,

                        decoration: InputDecoration(
                          hintText: 'Confirm password',

                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
                              });
                            },

                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,

                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // CREATE ACCOUNT BUTTON
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          return CustomButton(
                            text: auth.isLoading
                                ? 'Creating Account...'
                                : 'Create Account',

                            onPressed: () async {
                              if (passwordController.text !=
                                  confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Passwords do not match'),
                                  ),
                                );

                                return;
                              }

                              final error = await auth.register(
                                firstName: firstNameController.text,

                                lastName: lastNameController.text,

                                email: emailController.text,

                                username: usernameController.text,

                                password: passwordController.text,

                                dob: dobController.text,
                              );

                              if (!context.mounted) return;

                              if (error != null) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(error)));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Account created successfully',
                                    ),
                                  ),
                                );

                                context.go('/dashboard');
                              }
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // DIVIDER
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey.shade300,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),

                            child: Text(
                              'OR',

                              style: TextStyle(
                                color: Colors.grey.shade500,

                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // GOOGLE BUTTON
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),

                          side: BorderSide(color: Colors.grey.shade300),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),

                        onPressed: () {},

                        icon: const Icon(
                          Icons.g_mobiledata_rounded,
                          size: 30,
                          color: AppColors.primary,
                        ),

                        label: const Text(
                          'Continue with Google',

                          style: TextStyle(
                            color: AppColors.textPrimary,

                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // LOGIN REDIRECT
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      const Text(
                        'Already have an account? ',

                        style: TextStyle(color: AppColors.textSecondary),
                      ),

                      GestureDetector(
                        onTap: () {
                          context.push('/login');
                        },

                        child: const Text(
                          'Login',

                          style: TextStyle(
                            color: AppColors.primary,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
