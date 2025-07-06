import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../services/member_service.dart';
import '../models/member.dart';
import '../utils/toast_utils.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      final currentContext = context;
      if (_isProcessing || scanData.code == null) return;
      
      setState(() => _isProcessing = true);
      controller.pauseCamera();

      try {
        final member = await MemberService().getMemberByTag(scanData.code!);
        if (!mounted) return;

        if (member != null) {
          await _showMemberDialog(member, currentContext);
        } else {
          ToastUtils.showWarningToast(currentContext, 'Member not found');
        }
      } catch (e) {
        ToastUtils.showErrorToast(currentContext, 'Error: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
          controller.resumeCamera();
        }
      }
    });
  }

  Future<void> _showMemberDialog(Member member, BuildContext dialogContext) async {
    return showDialog(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: const Text('Member Found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${member.name}'),
            Text('Member Number: ${member.memberNumber}'),
            Text('Jamaat: ${member.jamaat}'),
            Text('Circuit: ${member.circuit}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await MemberService().checkInMember(member, '1'); // Mock user ID
                if (!mounted) return;
                Navigator.pop(context);
                ToastUtils.showSuccessToast(dialogContext, 'Member checked in successfully');
              } catch (e) {
                ToastUtils.showErrorToast(dialogContext, 'Error: ${e.toString()}');
              }
            },
            child: const Text('Check In'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Member'),
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Theme.of(context).primaryColor,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300,
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
} 