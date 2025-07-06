import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/member_service.dart';
import '../models/member.dart';
import '../utils/toast_utils.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _jamaatController = TextEditingController();
  final _circuitController = TextEditingController();
  List<Member>? _searchResults;
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    _jamaatController.dispose();
    _circuitController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() => _isLoading = true);

    try {
      final results = await MemberService().searchMembers(
        query: _searchController.text.isNotEmpty ? _searchController.text : null,
        jamaat: _jamaatController.text.isNotEmpty ? _jamaatController.text : null,
        circuit: _circuitController.text.isNotEmpty ? _circuitController.text : null,
      );

      if (!mounted) return;
      setState(() => _searchResults = results);
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showErrorToast(context, 'Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkInMember(Member member) async {
    try {
      await MemberService().checkInMember(member, '1'); // Mock user ID
      if (!mounted) return;
      ToastUtils.showSuccessToast(context, 'Member checked in successfully');
      _search(); // Refresh the list
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showErrorToast(context, 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Member'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search by Name or Member Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _jamaatController,
                        decoration: const InputDecoration(
                          labelText: 'Jamaat',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _circuitController,
                        decoration: const InputDecoration(
                          labelText: 'Circuit',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _search,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _searchResults == null
                ? const Center(
                    child: Text('Enter search criteria and tap Search'),
                  )
                : _searchResults!.isEmpty
                    ? const Center(
                        child: Text('No members found'),
                      )
                    : ListView.builder(
                        itemCount: _searchResults!.length,
                        itemBuilder: (context, index) {
                          final member = _searchResults![index];
                          return ListTile(
                            title: Text(member.name),
                            subtitle: Text(
                              '${member.memberNumber} - ${member.jamaat}, ${member.circuit}',
                            ),
                            trailing: member.isCheckedIn
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : TextButton(
                                    onPressed: () => _checkInMember(member),
                                    child: const Text('Check In'),
                                  ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 