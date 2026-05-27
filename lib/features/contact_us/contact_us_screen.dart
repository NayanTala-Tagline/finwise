import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../extension/ext_context.dart';
import '../../extension/ext_string_alert.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/remote_config.dart';
import '../../widgets/ad_slot.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_textfield.dart';
import '../../widgets/common_appbar.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  InlineAdManager? _inlineAd;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? '';
    _emailController.text = user?.email ?? '';
    AnalyticsManager.instance.logScreenView(screenName: 'contact_us_screen');
    _loadInline();
  }

  void _loadInline() {
    final data = RemoteConfigService.instance.contactNative;
    if (!data.enabled || data.adId.isEmpty) return;
    _inlineAd = InlineAdManager(adData: data);
    unawaited(_inlineAd!.load());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    unawaited(_inlineAd?.dispose());
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await FirebaseFirestore.instance.collection('contact_us').add({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'description': _descriptionController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
      });
      AnalyticsManager.instance.logEvent(name: 'contact_us_submit_success');
      if (!mounted) return;
      'Message sent successfully!'.showSuccessAlert();
      NavigationHelper().handleBackPress(context);
    } catch (e) {
      AnalyticsManager.instance.logEvent(
        name: 'contact_us_submit_failed',
        parameters: {'error': e.toString()},
      );
      'Failed to send message. Please try again.'.showErrorAlert();
      print(e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        NavigationHelper().handleBackPress(context);
      },
      child: Scaffold(
        backgroundColor: colors.backgroundColor,
        bottomNavigationBar: AdSlot(ad: _inlineAd),
        appBar: CommonAppBar(
          titleText: 'Contact Us',
          titleTextStyle: context.textTheme.bodyMedium?.copyWith(
            fontSize: AppSize.sp18,
            fontWeight: FontWeight.w700,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.w16,
                  vertical: AppSize.h16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextFormField(
                        title: 'Name',
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        hintText: 'Enter your name',
                        onChanged: (_) {},
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Name is required';
                          return null;
                        },
                      ),
                      SizedBox(height: AppSize.h16),
                      AppTextFormField(
                        title: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'Enter your email',
                        onChanged: (_) {},
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Email is required';
                          final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!emailRegex.hasMatch(value.trim())) return 'Please enter a valid email';
                          return null;
                        },
                      ),
                      SizedBox(height: AppSize.h16),
                      AppTextFormField(
                        title: 'Message',
                        controller: _descriptionController,
                        hintText: 'Write your message here...',
                        keyboardType: TextInputType.multiline,
                        minLine: 5,
                        maxLine: 8,
                        maxTextLength: 1000,
                        textAlignVertical: TextAlignVertical.top,
                        onChanged: (_) {},
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Message is required';
                          return null;
                        },
                      ),
                      SizedBox(height: AppSize.h8),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x26000000),
                    offset: Offset(0, -1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSize.w16,
                    AppSize.h12,
                    AppSize.w16,
                    AppSize.h16,
                  ),
                  child: AppButton(
                    text: 'Submit',
                    backgroundColor: colors.primary,
                    borderRadius: AppSize.r50,
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
