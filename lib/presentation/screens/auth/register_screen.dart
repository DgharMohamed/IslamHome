import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/data/services/auth_service.dart';
import 'package:islam_home/data/services/firestore_sync_service.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/presentation/widgets/auth/auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final bool isUpgrading;

  const RegisterScreen({super.key, this.isUpgrading = false});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);

      if (widget.isUpgrading && authService.currentUser != null) {
        await authService.linkAnonymousWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );
      } else {
        await authService.registerWithEmail(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      // Initial migration of local data to Cloud
      await ref.read(firestoreSyncServiceProvider).syncLocalToCloud();

      if (mounted) context.pop();
    } catch (e) {
      setState(() => _errorMessage = _getFriendlyErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleRegister() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ref.read(authServiceProvider).signInWithGoogle();
      if (result == null) {
        if (mounted) setState(() => _isGoogleLoading = false);
        return;
      }

      await ref.read(firestoreSyncServiceProvider).syncLocalToCloud();

      if (mounted) context.pop();
    } catch (e) {
      setState(() => _errorMessage = _getFriendlyErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  String _getFriendlyErrorMessage(dynamic e) {
    final err = e.toString().toLowerCase();
    if (err.contains('email-already-in-use')) {
      return 'هذا البريد الإلكتروني مستخدم بالفعل';
    }
    if (err.contains('weak-password')) return 'كلمة المرور ضعيفة جداً';
    if (err.contains('invalid-email')) return 'البريد الإلكتروني غير صالح';
    if (err.contains('network-request-failed')) {
      return 'لا يوجد اتصال بالإنترنت';
    }
    return 'حدث خطأ أثناء إنشاء الحساب. يرجى المحاولة لاحقاً';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: AuthBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    // Logo
                    Hero(
                      tag: 'auth_logo',
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        ),
                        child: const Icon(
                          Icons.mosque_rounded,
                          size: 72,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.isUpgrading
                          ? 'ربط الحساب بالسحابة'
                          : 'إنشاء حساب جديد',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Registration Form
                    GlassCard(
                      child: Column(
                        children: [
                          if (widget.isUpgrading)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.cloud_sync_rounded,
                                      color: AppTheme.primaryColor,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'سيتم نقل ختماتك وتسبيحاتك الحالية إلى حسابك الجديد تلقائياً.',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          AuthTextField(
                            controller: _nameController,
                            label: 'الاسم الكامل',
                            icon: Icons.person_outline_rounded,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'يرجى إدخال الاسم'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          AuthTextField(
                            controller: _emailController,
                            label: 'البريد الإلكتروني',
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => (v == null || !v.contains('@'))
                                ? 'يرجى إدخال بريد صحيح'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          AuthTextField(
                            controller: _passwordController,
                            label: 'كلمة المرور',
                            icon: Icons.lock_outline_rounded,
                            obscureText: true,
                            validator: (v) => (v == null || v.length < 6)
                                ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                                : null,
                          ),
                          const SizedBox(height: 32),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          AuthButton(
                            onPressed: (_isLoading || _isGoogleLoading)
                                ? null
                                : _handleRegister,
                            text: widget.isUpgrading
                                ? 'ربط الحساب'
                                : 'إنشاء الحساب',
                            isLoading: _isLoading,
                          ),
                          const SizedBox(height: 20),
                          const AuthDivider(),
                          const SizedBox(height: 20),
                          SocialAuthButton(
                            onPressed: (_isLoading || _isGoogleLoading)
                                ? null
                                : _handleGoogleRegister,
                            isLoading: _isGoogleLoading,
                            icon: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Text(
                                'G',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF4285F4),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  height: 1.15,
                                ),
                              ),
                            ),
                            label: widget.isUpgrading
                                ? 'ربط الحساب مع Google'
                                : 'إنشاء حساب مع Google',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Footer Actions
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'لديك حساب بالفعل؟',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
