import 'package:flutter/material.dart';

class MemberRegistrationScreen extends StatefulWidget {
  const MemberRegistrationScreen({Key? key}) : super(key: key);

  @override
  _MemberRegistrationScreenState createState() => _MemberRegistrationScreenState();
}

class _MemberRegistrationScreenState extends State<MemberRegistrationScreen> {
  final List<TextEditingController> _membershipControllers = [];
  final _formKey = GlobalKey<FormState>();

  void _addMembershipField() {
    setState(() {
      _membershipControllers.add(TextEditingController());
    });
  }

  void _removeMembershipField(int index) {
    setState(() {
      _membershipControllers[index].dispose();
      _membershipControllers.removeAt(index);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Get all non-empty membership numbers
      final List<String> membershipNumbers = _membershipControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (membershipNumbers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one membership number')),
        );
        return;
      }

      // TODO: Process the membership numbers (e.g., send to API)
      print('Membership numbers to register: $membershipNumbers');
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Members registered successfully!')),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _membershipControllers) {
      controller.dispose();
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
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _membershipControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Membership Number ${index + 1}',
                                border: const OutlineInputBorder(),
                              ),
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
                    onPressed: _submitForm,
                    icon: const Icon(Icons.check),
                    label: const Text('Register All'),
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