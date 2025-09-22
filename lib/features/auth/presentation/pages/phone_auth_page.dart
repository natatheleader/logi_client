import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart' hide pop, push;
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../cubit/phone_auth_cubit.dart';
import '../widgets/phone_input_field.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/auth_button.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late PageController _pageController;
  
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _otpFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _phoneFocusNode.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PhoneAuthCubit>(),
      child: BlocListener<PhoneAuthCubit, PhoneAuthState>(
        listener: (context, state) {
          if (state.isCodeSent) {
            _moveToOtpPage();
          } else if (state.isVerified) {
            context.go(AppRoutes.home);
          } else if (state.hasError && state.error != null) {
            context.showErrorSnackBar(state.error!);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            ),
            title: Text(
              'Phone Authentication',
              style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
            ),
            centerTitle: true,
          ),
          body: FadeTransition(
            opacity: _fadeController,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPhoneInputPage(),
                _buildOtpInputPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInputPage() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xl),
            
            // Illustration
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Center(
                child: Icon(
                  Icons.phone_android_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            Text(
              'Enter your phone number',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            Text(
              'We\'ll send you a verification code to confirm your number',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            PhoneInputField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              validator: Validators.phone,
              onChanged: (value) {
                // Clear any previous errors
                context.read<PhoneAuthCubit>().clearError();
              },
            ),
            
            const Spacer(),
            
            BlocBuilder<PhoneAuthCubit, PhoneAuthState>(
              builder: (context, state) {
                return AuthButton(
                  onTap: state.isLoading ? null : _sendVerificationCode,
                  text: 'Send Verification Code',
                  isLoading: state.isLoading,
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                );
              },
            ),
            
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpInputPage() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: BlocBuilder<PhoneAuthCubit, PhoneAuthState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              
              // Illustration
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Center(
                  child: Icon(
                    Icons.sms_rounded,
                    size: 80,
                    color: AppColors.accent,
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              Text(
                'Enter verification code',
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              Text(
                'We sent a code to ${state.phoneVerification?.phoneNumber ?? _phoneController.text}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              OtpInputField(
                controller: _otpController,
                focusNode: _otpFocusNode,
                onChanged: (value) {
                  context.read<PhoneAuthCubit>().clearError();
                  if (value.length == 6) {
                    _verifyCode();
                  }
                },
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Resend code button
              if (state.canResend)
                TextButton(
                  onPressed: state.isLoading ? null : _resendCode,
                  child: Text(
                    'Didn\'t receive code? Resend',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              
              const Spacer(),
              
              AuthButton(
                onTap: state.isVerifying ? null : _verifyCode,
                text: 'Verify Code',
                isLoading: state.isVerifying,
                backgroundColor: AppColors.accent,
                textColor: Colors.white,
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              TextButton(
                onPressed: _goBackToPhoneInput,
                child: Text(
                  'Change phone number',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
            ],
          );
        },
      ),
    );
  }

  void _sendVerificationCode() {
    if (_formKey.currentState?.validate() ?? false) {
      final phoneNumber = _phoneController.text.trim();
      context.read<PhoneAuthCubit>().sendVerificationCode(phoneNumber);
      
      // Add haptic feedback
      HapticFeedback.mediumImpact();
    }
  }

  void _verifyCode() {
    final code = _otpController.text.trim();
    if (code.length == 6) {
      context.read<PhoneAuthCubit>().verifyCode(code);
      
      // Add haptic feedback
      HapticFeedback.mediumImpact();
    } else {
      context.showErrorSnackBar('Please enter a valid 6-digit code');
    }
  }

  void _resendCode() {
    context.read<PhoneAuthCubit>().resendCode();
    
    // Add haptic feedback
    HapticFeedback.lightImpact();
  }

  void _moveToOtpPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
    // Auto focus on OTP field
    Future.delayed(const Duration(milliseconds: 500), () {
      _otpFocusNode.requestFocus();
    });
  }

  void _goBackToPhoneInput() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
    // Clear OTP and reset state
    _otpController.clear();
    context.read<PhoneAuthCubit>().resetState();
    
    // Add haptic feedback
    HapticFeedback.lightImpact();
  }
}
