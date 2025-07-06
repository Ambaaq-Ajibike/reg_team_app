import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../services/member_service.dart';
import '../services/api_service.dart';
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
  String _processingMessage = 'Processing...';

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
      
      setState(() {
        _isProcessing = true;
        _processingMessage = 'Processing...';
      });
      controller.pauseCamera();

      try {
        final scannedCode = scanData.code!;
        
        // Check if it's a URL
        if (scannedCode.startsWith('http')) {
          await _handleUrlScan(scannedCode, currentContext);
        } else {
          // Handle member tag scan (existing functionality)
          setState(() => _processingMessage = 'Looking up member...');
          final member = await MemberService().getMemberByTag(scannedCode);
          if (!mounted) return;

          if (member != null) {
            await _showMemberDialog(member, currentContext);
          } else {
            ToastUtils.showWarningToast(currentContext, 'Member not found');
          }
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

  Future<void> _handleUrlScan(String url, BuildContext currentContext) async {
    try {
      final uri = Uri.parse(url);
      
      // Check for participant check-in URL pattern
      if (uri.host.contains('jarms.ahmadiyyanigeria.net') && 
          uri.path.contains('checkIn') && 
          uri.queryParameters.containsKey('regNo')) {
        
        setState(() => _processingMessage = 'Checking in participant...');
        final regNo = uri.queryParameters['regNo']!;
        final response = await ApiService.checkInParticipant(regNo);
        
        if (!mounted) return;
        
        if (response != null) {
          if (response.status) {
            ToastUtils.showSuccessToast(currentContext, response.message);
          } else {
            ToastUtils.showWarningToast(currentContext, response.message);
          }
        } else {
          ToastUtils.showErrorToast(currentContext, 'Failed to check in participant');
        }
      }
      // Check for manifest scan URL pattern
      else if ((uri.host.contains('localhost') || uri.host.contains('jarms.ahmadiyyanigeria.net')) && 
               uri.path.contains('Manifest') && 
               uri.queryParameters.containsKey('QRCode')) {
        
        setState(() => _processingMessage = 'Scanning manifest...');
        final qrCode = uri.queryParameters['QRCode']!;
        final response = await ApiService.scanManifest(qrCode);
        
        if (!mounted) return;
        
        if (response != null) {
          if (response.status) {
            ToastUtils.showSuccessToast(currentContext, response.message);
          } else {
            ToastUtils.showWarningToast(currentContext, response.message);
          }
        } else {
          ToastUtils.showErrorToast(currentContext, 'Failed to scan manifest');
        }
      }
      // Unknown URL pattern
      else {
        ToastUtils.showWarningToast(currentContext, 'Unknown URL pattern: $url');
      }
    } catch (e) {
      ToastUtils.showErrorToast(currentContext, 'Error processing URL: ${e.toString()}');
    }
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
        title: const Text('Scan QR Code'),
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      _processingMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
} 