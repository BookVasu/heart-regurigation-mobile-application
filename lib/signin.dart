// lib/signin.dart
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
    this.onBack,
    this.onLogin,
    this.onForgotPassword,
    this.footerText = '2MB development',
    this.logoAsset = 'asset/heart_icon_logo.png',
  });

  final VoidCallback? onBack;

  /// Called when user presses LOG IN (you get email/phone + password).
  final void Function(String user, String password)? onLogin;

  final VoidCallback? onForgotPassword;

  final String footerText;
  final String logoAsset;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // same gradient family as your other screens
  static const _cTop = Color(0xFFC3C0FA);
  static const _cMid = Color(0xFFF4E0F0);
  static const _cNearWhite = Color(0xFFFFFEFE);
  static const _cWhite = Color(0xFFFFFFFF);

  static const _btnPurple = Color(0xFF9A9CEC);

  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final _userFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _obscure = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _userFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text;
    widget.onLogin?.call(user, pass);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_cTop, _cMid, _cNearWhite, _cWhite],
              stops: [0.0, 0.48, 0.72, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // faint background "report" pattern
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.18,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, right: 8),
                          child: Transform.rotate(
                            angle: -0.18,
                            child: Image.asset(
                              'asset/report_bg.png',
                              width: 220,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // top row
                Positioned(
                  left: 6,
                  top: 6,
                  child: IconButton(
                    onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ),

                // content
                Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 88),
                    child: Column(
                      children: [
                        // title row (matches screenshot)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: Text(
                              'Login',
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // heart
                              Image.asset(
                                widget.logoAsset,
                                width: 120,
                                height: 120,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 18),

                              _InputPill(
                                controller: _userCtrl,
                                focusNode: _userFocus,
                                nextFocus: _passFocus,
                                hint: 'Enter email or phone number',
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 14),

                              _InputPill(
                                controller: _passCtrl,
                                focusNode: _passFocus,
                                hint: 'Password',
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submit(),
                                suffix: IconButton(
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // LOG IN button
                              SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _btnPurple,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                  ),
                                  child: const Text(
                                    'LOG IN',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // FORGET PASSWORD
                              GestureDetector(
                                onTap: widget.onForgotPassword,
                                child: const Text(
                                  'FORGET PASSWORD?',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.italic,
                                    decoration: TextDecoration.underline,
                                    color: Colors.black,
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

                // footer line + text
                Positioned(
                  left: 22,
                  right: 22,
                  bottom: 18,
                  child: Column(
                    children: [
                      Container(
                        height: 1,
                        color: const Color(0xFFBDBDBD).withOpacity(0.35),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.footerText,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFBDBDBD),
                          fontWeight: FontWeight.w400,
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
    );
  }
}

class _InputPill extends StatelessWidget {
  const _InputPill({
    required this.controller,
    this.focusNode,
    this.nextFocus,
    required this.hint,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;

  final String hint;
  final bool obscureText;
  final Widget? suffix;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.55), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: (v) {
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          }
          onSubmitted?.call(v);
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 12,
            color: Colors.black.withOpacity(0.55),
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          isCollapsed: true,
          suffixIcon: suffix == null ? null : SizedBox(width: 40, child: Center(child: suffix)),
        ),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }
}
