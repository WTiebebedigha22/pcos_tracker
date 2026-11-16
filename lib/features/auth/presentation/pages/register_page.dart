import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pcos_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/feedback/toast.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../../../../shared/widgets/medical_disclaimer.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _localLoading = false;
  bool _acceptedTerms = false;
  DateTime? _dob;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'Select your date of birth',
    );
    if (picked == null) return;
    setState(() {
      _dob = picked;
      // ISO 8601 (yyyy-MM-dd) — what Supabase/Postgres `date` expects.
      _dobController.text = picked.toIso8601String().split('T').first;
    });
  }

  Future<void> _handleRegister(AuthProvider auth) async {
    if (_localLoading || auth.isLoading) return;
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_acceptedTerms) {
      Toast.show(context, 'Please accept the Privacy Policy and Terms to continue',
          error: true);
      return;
    }

    setState(() => _localLoading = true);
    final error = await auth.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      dob: _dobController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _localLoading = false);

    if (error != null) {
      Toast.show(context, error, error: true);
    } else {
      Toast.show(context, 'Account created successfully!');
      context.go(RouteNames.dashboard);
    }
  }

  Future<void> _handleGoogleSignIn(AuthProvider auth) async {
    if (_localLoading || auth.isLoading) return;
    FocusScope.of(context).unfocus();

    if (!_acceptedTerms) {
      Toast.show(context, 'Please accept the Privacy Policy and Terms to continue',
          error: true);
      return;
    }

    setState(() => _localLoading = true);
    final error = await auth.signInWithGoogle();
    if (!mounted) return;
    setState(() => _localLoading = false);

    if (error != null) {
      Toast.show(context, error, error: true);
    } else {
      context.go(RouteNames.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final busy = _localLoading;

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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Back
                  Semantics(
                    label: 'Back',
                    button: true,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Logo
                  Center(
                    child: Semantics(
                      label: 'Lunora logo',
                      image: true,
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
                              color: AppColors.primary.withValues(alpha: 0.25),
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
                  ),

                  const SizedBox(height: 26),

                  // Heading
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Create Account ✨',
                          textAlign: TextAlign.center,
                          style: t.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Start tracking your wellness and cycle journey',
                          textAlign: TextAlign.center,
                          style: t.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Form card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // First name
                        const Text(
                          'First Name',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _firstNameController,
                          hintText: 'Enter first name',
                          textInputAction: TextInputAction.next,
                          enabled: !busy,
                          validator: (v) {
                            if ((v ?? '').trim().isEmpty) return 'First name is required';
                            if ((v ?? '').trim().length < 2) return 'At least 2 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),

                        // Last name
                        const Text(
                          'Last Name',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _lastNameController,
                          hintText: 'Enter last name',
                          textInputAction: TextInputAction.next,
                          enabled: !busy,
                          validator: (v) {
                            if ((v ?? '').trim().isEmpty) return 'Last name is required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),

                        // Email
                        const Text(
                          'Email Address',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          enabled: !busy,
                          validator: (v) {
                            final s = (v ?? '').trim();
                            if (s.isEmpty) return 'Email is required';
                            final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
                            if (!ok) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),

                        // DOB
                        const Text(
                          'Date of Birth',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _dobController,
                          readOnly: true,
                          enabled: !busy,
                          onTap: _selectDate,
                          validator: (_) =>
                              (_dob == null) ? 'Date of birth is required' : null,
                          decoration: const InputDecoration(
                            hintText: 'Select date of birth',
                            suffixIcon: Icon(Icons.calendar_month_rounded),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Username
                        const Text(
                          'Username',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _usernameController,
                          hintText: 'Choose username',
                          textInputAction: TextInputAction.next,
                          enabled: !busy,
                          validator: (v) {
                            final s = (v ?? '').trim();
                            if (s.isEmpty) return 'Username is required';
                            if (s.length < 3) return 'At least 3 characters';
                            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(s)) {
                              return 'Letters, numbers, and underscores only';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),

                        // Password
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          enabled: !busy,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (v.length < 8) return 'Use at least 8 characters';
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Create password (min 8 characters)',
                            suffixIcon: Semantics(
                              label: _obscurePassword ? 'Show password' : 'Hide password',
                              button: true,
                              child: IconButton(
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Confirm password
                        const Text(
                          'Confirm Password',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          enabled: !busy,
                          textInputAction: TextInputAction.done,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Confirm your password';
                            if (v != _passwordController.text) return 'Passwords do not match';
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Confirm password',
                            suffixIcon: Semantics(
                              label: _obscureConfirm
                                  ? 'Show password'
                                  : 'Hide password',
                              button: true,
                              child: IconButton(
                                onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Terms + privacy
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _acceptedTerms,
                              onChanged: busy
                                  ? null
                                  : (v) => setState(() => _acceptedTerms = v ?? false),
                            ),
                            const Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Text(
                                  'I agree to the Privacy Policy and Terms of Service. '
                                  'Lunora is not a medical device.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Submit
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) => AppButton(
                            label: 'Create Account',
                            loading: _localLoading || auth.isLoading,
                            onPressed: () => _handleRegister(auth),
                            expand: true,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Divider
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
                                  color: Colors.grey.shade600,
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

                        // Google
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) => Semantics(
                            button: true,
                            label: 'Continue with Google',
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 56),
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: (_localLoading || auth.isLoading)
                                  ? null
                                  : () => _handleGoogleSignIn(auth),
                              icon: const Icon(
                                Icons.g_mobiledata_rounded,
                                size: 30,
                                color: AppColors.primary,
                              ),
                              label: Text(
                                (_localLoading || auth.isLoading)
                                    ? 'Signing in...'
                                    : 'Continue with Google',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const MedicalDisclaimer(compact: true),
                  const SizedBox(height: 16),

                  // Login link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        Semantics(
                          button: true,
                          label: 'Log in',
                          child: GestureDetector(
                            onTap: busy ? null : () => context.push(RouteNames.login),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 4,
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}