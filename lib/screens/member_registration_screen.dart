import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../models/member_details.dart';
import '../utils/toast_utils.dart';

class MemberRegistrationScreen extends StatefulWidget {
  const MemberRegistrationScreen({super.key});

  @override
  State<MemberRegistrationScreen> createState() => _MemberRegistrationScreenState();
}

class _MemberRegistrationScreenState extends State<MemberRegistrationScreen> {
  final List<TextEditingController> _membershipControllers = [];
  final List<MemberDetails?> _memberDetails = [];
  final List<bool> _loadingStates = [];
  final List<Timer?> _debounceTimers = [];
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  void _addMembershipField() {
    setState(() {
      _membershipControllers.add(TextEditingController());
      _memberDetails.add(null);
      _loadingStates.add(false);
      _debounceTimers.add(null);
    });
  }

  void _removeMembershipField(int index) {
    _debounceTimers[index]?.cancel();
    setState(() {
      _membershipControllers[index].dispose();
      _membershipControllers.removeAt(index);
      _memberDetails.removeAt(index);
      _loadingStates.removeAt(index);
      _debounceTimers.removeAt(index);
    });
  }

  Future<void> _fetchMemberDetails(int index) async {
    final memberNumber = _membershipControllers[index].text.trim();
    if (memberNumber.isEmpty) {
      setState(() {
        _memberDetails[index] = null;
        _loadingStates[index] = false;
      });
      return;
    }

    setState(() {
      _loadingStates[index] = true;
    });

    try {
      final memberDetails = await ApiService.getMemberDetails(memberNumber);
      if (mounted) {
        setState(() {
          _memberDetails[index] = memberDetails;
          _loadingStates[index] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingStates[index] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching member details: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Get all non-empty membership numbers
      final List<String> membershipNumbers = _membershipControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (membershipNumbers.isEmpty) {
        ToastUtils.showWarningToast(context, 'Please add at least one membership number');
        return;
      }

      // Show confirmation toast
      ToastUtils.showInfoToast(context, 'Registering ${membershipNumbers.length} member(s)...');

      setState(() {
        _isSubmitting = true;
      });

      try {
        final response = await ApiService.bulkRegisterMembers(membershipNumbers);
        
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });

          if (response != null) {
            // Show all messages as toasts
            if (response.messages.isNotEmpty) {
              ToastUtils.showMultipleToasts(context, response.messages);
            }

            // If registration was successful, clear the form
            if (response.succeeded && response.data.isNotEmpty) {
              // Clear all fields
              for (var controller in _membershipControllers) {
                controller.clear();
              }
              setState(() {
                _memberDetails.clear();
                _loadingStates.clear();
                _debounceTimers.clear();
              });
              
              // Show success toast
              ToastUtils.showSuccessToast(context, 'Successfully registered ${response.data.length} member(s)');
            }
          } else {
            ToastUtils.showErrorToast(context, 'Failed to register members. Please try again.');
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

  @override
  void dispose() {
    for (var controller in _membershipControllers) {
      controller.dispose();
    }
    for (var timer in _debounceTimers) {
      timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Members'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Enter Membership Numbers',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _membershipControllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _membershipControllers[index],
                                  decoration: InputDecoration(
                                    labelText: 'Membership Number ${index + 1}',
                                    border: const OutlineInputBorder(),
                                    suffixIcon: _loadingStates.length > index && _loadingStates[index]
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
                                            onPressed: () => _fetchMemberDetails(index),
                                          ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {
                                    // Clear member details when text changes
                                    if (_memberDetails.length > index) {
                                      setState(() {
                                        _memberDetails[index] = null;
                                      });
                                    }
                                    
                                    // Cancel previous timer
                                    _debounceTimers[index]?.cancel();
                                    
                                    // Set new timer for auto-fetch
                                    if (value.trim().isNotEmpty) {
                                      _debounceTimers[index] = Timer(const Duration(milliseconds: 800), () {
                                        _fetchMemberDetails(index);
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a membership number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _removeMembershipField(index),
                                color: Colors.red,
                              ),
                            ],
                          ),
                          if (_memberDetails.length > index && _memberDetails[index] != null) ...[
                            const SizedBox(height: 8),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _memberDetails[index]!.fullName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _addMembershipField,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Member'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitForm,
                    icon: _isSubmitting 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(_isSubmitting ? 'Registering...' : 'Register All'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 