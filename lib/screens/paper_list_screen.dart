import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../services/member_service.dart';
import '../models/member.dart';

class PaperListScreen extends StatefulWidget {
  const PaperListScreen({super.key});

  @override
  State<PaperListScreen> createState() => _PaperListScreenState();
}

class _PaperListScreenState extends State<PaperListScreen> {
  final _textRecognizer = TextRecognizer();
  File? _imageFile;
  bool _isProcessing = false;
  List<String> _detectedNumbers = [];
  List<Member> _foundMembers = [];

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo == null) return;

    setState(() {
      _imageFile = File(photo.path);
      _detectedNumbers = [];
      _foundMembers = [];
      _isProcessing = true;
    });

    try {
      final inputImage = InputImage.fromFile(_imageFile!);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Extract member numbers using a simple pattern
      final RegExp memberNumberPattern = RegExp(r'M\d{3}');
      final numbers = memberNumberPattern
          .allMatches(recognizedText.text)
          .map((m) => m.group(0)!)
          .toList();

      setState(() => _detectedNumbers = numbers);

      // Search for members
      final List<Member> members = [];
      for (final number in numbers) {
        try {
          final member = await MemberService().getMemberByTag(number);
          if (member != null) {
            members.add(member);
          }
        } catch (_) {
          // Skip invalid numbers
        }
      }

      setState(() => _foundMembers = members);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _checkInSelected() async {
    final selectedMembers =
        _foundMembers.where((member) => !member.isCheckedIn).toList();

    if (selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No members to check in')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      for (final member in selectedMembers) {
        await MemberService().checkInMember(member, '1'); // Mock user ID
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All selected members checked in successfully'),
        ),
      );

      // Reset the screen
      setState(() {
        _imageFile = null;
        _detectedNumbers = [];
        _foundMembers = [];
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paper List Scanner'),
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_imageFile == null) ...[
                    const Icon(
                      Icons.camera_alt,
                      size: 128,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Take a picture of the paper list',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _takePicture,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Picture'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ] else ...[
                    Image.file(
                      _imageFile!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Found ${_detectedNumbers.length} member numbers',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    if (_foundMembers.isNotEmpty) ...[
                      Text(
                        'Matched Members (${_foundMembers.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _foundMembers.length,
                          itemBuilder: (context, index) {
                            final member = _foundMembers[index];
                            return ListTile(
                              title: Text(member.name),
                              subtitle: Text(
                                '${member.memberNumber} - ${member.jamaat}',
                              ),
                              trailing: member.isCheckedIn
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                  : null,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _checkInSelected,
                        icon: const Icon(Icons.check),
                        label: const Text('Check In All'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _takePicture,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Take Another Picture'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
} 