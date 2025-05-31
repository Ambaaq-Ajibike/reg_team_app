import 'package:flutter/material.dart';
import '../models/guest.dart';

class GuestRegistrationScreen extends StatefulWidget {
  const GuestRegistrationScreen({Key? key}) : super(key: key);

  @override
  _GuestRegistrationScreenState createState() => _GuestRegistrationScreenState();
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

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _guestOwnerController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final guest = Guest(
        guestOwner: _guestOwnerController.text,
        lastName: _lastNameController.text,
        firstName: _firstNameController.text,
        middleName: _middleNameController.text,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
        gender: _selectedGender,
        address: _addressController.text,
      );

      // TODO: Process the guest registration (e.g., send to API)
      print('Guest to register: ${guest.toJson()}');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guest registered successfully!')),
      );

      // Clear form
      _formKey.currentState!.reset();
      _selectedGender = 'Male';
      setState(() {});
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
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
          if (value == null || value.trim().isEmpty) {
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
              _buildTextField(
                label: 'Guest Owner',
                controller: _guestOwnerController,
              ),
              _buildTextField(
                label: 'Last Name',
                controller: _lastNameController,
              ),
              _buildTextField(
                label: 'First Name',
                controller: _firstNameController,
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
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (!RegExp(r'^\+?[\d\s-]+$').hasMatch(value)) {
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
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.check),
                label: const Text('Register Guest'),
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