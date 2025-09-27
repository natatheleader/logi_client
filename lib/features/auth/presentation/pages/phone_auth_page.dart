import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart' hide pop, push;
import 'package:country_code_picker/country_code_picker.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../cubit/phone_auth_cubit.dart';
import '../cubit/auth_cubit.dart'; // Add this import
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
  late ScrollController _scrollController;
  
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _otpFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  String _countryCode = '+1';
  String _countryFlag = '🇺🇸';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController.forward();

    // Listen to keyboard visibility
    _phoneFocusNode.addListener(() {
      if (_phoneFocusNode.hasFocus) {
        _scrollToBottom();
      }
    });

    _otpFocusNode.addListener(() {
      if (_otpFocusNode.hasFocus) {
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _phoneFocusNode.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PhoneAuthCubit>(
          create: (context) => getIt<PhoneAuthCubit>(),
        ),
        BlocProvider<AuthCubit>(
          create: (context) => getIt<AuthCubit>(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<PhoneAuthCubit, PhoneAuthState>(
            listener: (context, state) {
              if (state.isCodeSent) {
                _moveToOtpPage();
              } else if (state.isVerified && state.user != null) {
                // Phone verification successful, now exchange token with backend
                _exchangeFirebaseTokenWithBackend();
              } else if (state.hasError && state.error != null) {
                context.showErrorSnackBar(state.error!);
              }
            },
          ),
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state.isAuthenticated) {
                context.showSuccessSnackBar('Authentication successful!');
                context.go(AppRoutes.home);
              } else if (state.error != null) {
                context.showErrorSnackBar(state.error!);
              }
            },
          ),
        ],
        child: Scaffold(
          resizeToAvoidBottomInset: false, // Prevent automatic resize
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                  AppColors.accent.withOpacity(0.6),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Custom App Bar
                  _buildAppBar(context),
                  
                  // Page Content with scroll
                  Expanded(
                    child: FadeTransition(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back_ios, 
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          
          const Spacer(),
          
          Text(
            'Phone Authentication',
            style: AppTextStyles.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const Spacer(),
          
          // Invisible container for centering
          Container(width: 48),
        ],
      ),
    );
  }

  Widget _buildPhoneInputPage() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xl),
            
            // Illustration
            Container(
              height: 180,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.phone_android_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            Text(
              'Enter your phone number',
              style: AppTextStyles.h2.copyWith(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            Text(
              'We\'ll send you a verification code to confirm your number',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // White container for input field
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _buildPhoneInputWithCountryCode(),
            ),
            
            const SizedBox(height: AppSpacing.xl * 2),
            
            BlocBuilder<PhoneAuthCubit, PhoneAuthState>(
              builder: (context, state) {
                return AuthButton(
                  onTap: state.isLoading ? null : _sendVerificationCode,
                  text: 'Send Verification Code',
                  isLoading: state.isLoading,
                  backgroundColor: Colors.white,
                  textColor: AppColors.primary,
                );
              },
            ),
            
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInputWithCountryCode() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Country Code Picker - Fixed width
          SizedBox(
            width: 110, // Fixed width for country picker
            child: CountryCodePicker(
              onChanged: (countryCode) {
                setState(() {
                  _countryCode = countryCode.dialCode ?? '+1';
                  _countryFlag = countryCode.flagUri ?? '🇺🇸';
                });
                context.read<PhoneAuthCubit>().clearError();
              },
              initialSelection: 'US',
              favorite: const ['+1', 'US', '+44', 'GB', '+91', 'IN'],
              showCountryOnly: false,
              showOnlyCountryWhenClosed: false,
              alignLeft: false,
              showDropDownButton: true,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              searchStyle: AppTextStyles.bodyMedium,
              dialogTextStyle: AppTextStyles.bodyMedium,
              barrierColor: Colors.black54,
              backgroundColor: Colors.white,
              boxDecoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          
          // Divider
          Container(
            height: 30,
            width: 1,
            color: AppColors.grey.withOpacity(0.3),
            margin: const EdgeInsets.only(right: 12),
          ),
          
          // Phone number input - Takes remaining space
          Expanded(
            flex: 3, // Give more space to phone input
            child: TextFormField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              keyboardType: TextInputType.phone,
              validator: (value) => Validators.phone(value),
              onChanged: (value) {
                context.read<PhoneAuthCubit>().clearError();
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Phone number',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInputPage() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: BlocBuilder<PhoneAuthCubit, PhoneAuthState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              
              // Illustration
              Container(
                height: 180,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.sms_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              Text(
                'Enter verification code',
                style: AppTextStyles.h2.copyWith(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              Text(
                'We sent a code to $_countryCode ${state.phoneVerification?.phoneNumber ?? _phoneController.text}',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // White container for OTP input
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: OtpInputField(
                  controller: _otpController,
                  focusNode: _otpFocusNode,
                  onChanged: (value) {
                    context.read<PhoneAuthCubit>().clearError();
                    if (value.length == 6) {
                      _verifyCode();
                    }
                  },
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Resend code button
              if (state.canResend)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: TextButton(
                    onPressed: state.isLoading ? null : _resendCode,
                    child: Text(
                      'Didn\'t receive code? Resend',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(height: AppSpacing.xl),
              
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  return AuthButton(
                    onTap: (state.isVerifying || authState.isLoading) ? null : _verifyCode,
                    text: authState.isLoading ? 'Authenticating...' : 'Verify Code',
                    isLoading: state.isVerifying || authState.isLoading,
                    backgroundColor: Colors.white,
                    textColor: AppColors.accent,
                  );
                },
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              TextButton(
                onPressed: _goBackToPhoneInput,
                child: Text(
                  'Change phone number',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: Colors.white.withOpacity(0.8),
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
      final fullPhoneNumber = '$_countryCode${_phoneController.text.trim()}';
      context.read<PhoneAuthCubit>().sendVerificationCode(fullPhoneNumber);
      
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
    Future.delayed(const Duration(milliseconds: 800), () {
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

  void _exchangeFirebaseTokenWithBackend() async {
    try {
      // The phone verification is complete, Firebase user is signed in
      // Now trigger the complete authentication flow which will:
      // 1. Get the Firebase token from the current user
      // 2. Send it to the backend at /auth/firebase-login
      // 3. Get back the backend tokens and user data
      // 4. Store everything locally
      
      final authCubit = context.read<AuthCubit>();
      await authCubit.checkAuthStatus();
      
    } catch (e) {
      context.showErrorSnackBar('Authentication failed: ${e.toString()}');
    }
  }
}