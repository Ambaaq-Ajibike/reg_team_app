import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../utils/toast_utils.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const LoginScreen({
    super.key,
    required this.onThemeToggle,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final response = await ApiService.login(_usernameController.text);
        
        if (response.status) {
          // Get the token from SharedPreferences (stored by ApiService)
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          
          if (token != null) {
            // Set auth data in provider
            authProvider.setAuthData(token, response.data);
          } else {
            throw Exception('Token not received from server');
          }
          
          if (mounted) {
            ToastUtils.showSuccessToast(context, response.message);
            context.go('/home');
          }
        } else {
          if (mounted) {
            ToastUtils.showErrorToast(context, response.message);
          }
        }
      } catch (e) {
        if (mounted) {
          ToastUtils.showErrorToast(context, e.toString());
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Login'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 120,
              ),
              const SizedBox(height: 48),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Membership Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your member number';
                        }
                        return null;
                      },
                    ),
                   const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(fontSize: 18),
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
    );
  }
} 