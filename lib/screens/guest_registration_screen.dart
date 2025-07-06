import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/guest_registration.dart';
import '../models/member_details.dart';
import '../services/api_service.dart';
import '../utils/toast_utils.dart';

class GuestRegistrationScreen extends StatefulWidget {
  const GuestRegistrationScreen({super.key});

  @override
  State<GuestRegistrationScreen> createState() => _GuestRegistrationScreenState();
}

class _GuestRegistrationScreenState extends State<GuestRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _guestOwnerController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedGender = 'Male';
  bool _isSubmitting = false;
  MemberDetails? _guestOwnerDetails;
  bool _isValidatingOwner = false;
  Timer? _debounceTimer;

  final List<String> _genders = ['Male', 'Female', 'Other'];

  Future<void> _validateGuestOwner() async {
    final memberNumber = _guestOwnerController.text.trim();
    if (memberNumber.isEmpty) {
      setState(() {
        _guestOwnerDetails = null;
        _isValidatingOwner = false;
      });
      return;
    }

    setState(() {
      _isValidatingOwner = true;
    });

    try {
      final memberDetails = await ApiService.getMemberDetails(memberNumber);
      if (mounted) {
        setState(() {
          _guestOwnerDetails = memberDetails;
          _isValidatingOwner = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _guestOwnerDetails = null;
          _isValidatingOwner = false;
        });
        ToastUtils.showErrorToast(context, 'Error validating member: ${e.toString()}');
      }
    }
  }

  void _onGuestOwnerChanged(String value) {
    // Clear member details when text changes
    setState(() {
      _guestOwnerDetails = null;
    });
    
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Set new timer for auto-fetch
    if (value.trim().isNotEmpty) {
      _debounceTimer = Timer(const Duration(milliseconds: 800), () {
        _validateGuestOwner();
      });
    }
  }

  @override
  void dispose() {
    _guestOwnerController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Validate that guest owner is a valid member
      if (_guestOwnerDetails == null) {
        ToastUtils.showWarningToast(context, 'Please validate the guest owner member number first');
        return;
      }
      setState(() {
        _isSubmitting = true;
      });

      try {
        final request = GuestRegistrationRequest(
          guestOwner: _guestOwnerController.text.trim(),
          lastName: _lastNameController.text.trim(),
          firstName: _firstNameController.text.trim(),
          middleName: _middleNameController.text.trim().isEmpty 
              ? "" 
              : _middleNameController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim().isEmpty 
              ? "" 
              : _phoneNumberController.text.trim(),
          email: _emailController.text.trim().isEmpty 
              ? "" 
              : _emailController.text.trim(),
          gender: _selectedGender,
          address: _addressController.text.trim().isEmpty 
              ? "" 
              : _addressController.text.trim(),
        );

        final response = await ApiService.registerGuest(request);

        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });

          if (response != null) {
            if (response.succeeded) {
              // Show success message
              ToastUtils.showSuccessToast(
                context,
                response.messages.isNotEmpty 
                    ? response.messages.first 
                    : 'Guest registered successfully!'
              );

              // Clear all form fields
              _guestOwnerController.clear();
              _lastNameController.clear();
              _firstNameController.clear();
              _middleNameController.clear();
              _phoneNumberController.clear();
              _emailController.clear();
              _addressController.clear();
              
              // Reset gender and member details
              _selectedGender = 'Male';
              _guestOwnerDetails = null;
              
              setState(() {});
            } else {
              // Show error messages
              ToastUtils.showMultipleToasts(context, response.messages);
            }
          } else {
            ToastUtils.showErrorToast(context, 'Failed to register guest. Please try again.');
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          ToastUtils.showErrorToast(context, 'Error: ${e.toString()}');
        }
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: validator ?? (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Guest'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _guestOwnerController,
                    decoration: InputDecoration(
                      labelText: 'Guest Owner (Member Number)',
                      border: const OutlineInputBorder(),
                      suffixIcon: _isValidatingOwner
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: _validateGuestOwner,
                            ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: _onGuestOwnerChanged,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter guest owner member number';
                      }
                      return null;
                    },
                  ),
                  if (_guestOwnerDetails != null) ...[
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Member: ${_guestOwnerDetails!.fullName}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Jamaat: ${_guestOwnerDetails!.jamaatName}'),
                            Text('Circuit: ${_guestOwnerDetails!.circuitName}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              
              ),
              SizedBox(height: 16),
                              _buildTextField(
                  label: 'Last Name',
                  controller: _lastNameController,
                  isRequired: true,
                ),
                _buildTextField(
                  label: 'First Name',
                  controller: _firstNameController,
                  isRequired: true,
                ),
                              _buildTextField(
                  label: 'Middle Name',
                  controller: _middleNameController,
                ),
                _buildTextField(
                  label: 'Phone Number',
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty && !RegExp(r'^\+?[\d\s-]+$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: _genders.map((String gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    }
                  },
                ),
              ),
              _buildTextField(
                label: 'Address',
                controller: _addressController,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitForm,
                icon: _isSubmitting 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_isSubmitting ? 'Registering...' : 'Register Guest'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 