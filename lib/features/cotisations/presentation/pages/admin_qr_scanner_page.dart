import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class AdminQrScannerPage extends StatefulWidget {
  const AdminQrScannerPage({super.key});

  @override
  State<AdminQrScannerPage> createState() => _AdminQrScannerPageState();
}

class _AdminQrScannerPageState extends State<AdminQrScannerPage> {
  final MobileScannerController controller = MobileScannerController();
  bool _isFlashOn = false;
  bool _hasPermission = false;
  String? _scannedData;
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _availableCotisations = [
    {
      'id': 1,
      'title': 'Nouvelle école',
      'montantPersonnel': 2000,
      'color': const Color(0xFF3B82F6),
    },
    {
      'id': 2,
      'title': 'Festival annuel',
      'montantPersonnel': 1500,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'id': 3,
      'title': 'Obsèque Famille Allain',
      'montantPersonnel': 5000,
      'color': const Color(0xFFEC4899),
    },
    {
      'id': 4,
      'title': 'Rénovation mosquée',
      'montantPersonnel': 3000,
      'color': const Color(0xFF10B981),
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    // Check current status first
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
      });
      return;
    }

    // Request permission
    final result = await Permission.camera.request();
    if (result.isGranted) {
      setState(() {
        _hasPermission = true;
      });
      return;
    }

    // If permanently denied, show an explanatory dialog with a button to open app settings
    if (result.isPermanentlyDenied) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission requise'),
          content: const Text(
            'La permission d\'accéder à la caméra a été refusée définitivement. Veuillez l\'autoriser dans les réglages de l\'app pour utiliser le scanner.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              child: const Text('Ouvrir les réglages'),
            ),
          ],
        ),
      );
      return;
    }

    // Otherwise (denied but not permanently), keep hasPermission false so UI shows the prompt
    setState(() {
      _hasPermission = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (_hasPermission)
              MobileScanner(
                controller: controller,
                onDetect: _onDetect,
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt_outlined,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Permission caméra requise',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _checkCameraPermission,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                      ),
                      child: const Text('Demander la permission'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        await openAppSettings();
                      },
                      child: const Text(
                        'Ouvrir les réglages',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),

            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Scanner QR de paiement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (_hasPermission)
                    IconButton(
                      onPressed: _toggleFlash,
                      icon: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Scannez le QR code d\'un utilisateur',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Alignez le QR code dans le cadre pour enregistrer le paiement automatiquement',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_scannedData != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF10B981),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'QR scanné: $_scannedData',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (_isProcessing)
              Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF4F46E5),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Traitement en cours...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && !_isProcessing) {
      final barcode = barcodes.first;
      setState(() {
        _scannedData = barcode.rawValue;
        _isProcessing = true;
      });
      _processQRData(barcode.rawValue);
    }
  }

  void _toggleFlash() {
    controller.toggleTorch();
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  Future<void> _processQRData(String? qrData) async {
    if (qrData == null) {
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      final userData = _parseQRData(qrData);
      if (userData != null) {
        _showCotisationSelection(userData);
      } else {
        _showErrorDialog('QR code invalide');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erreur lors du traitement du QR code');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Map<String, dynamic>? _parseQRData(String qrData) {
    try {
      if (qrData.startsWith('USER:')) {
        final parts = qrData.substring(5).split('|');
        if (parts.length >= 3) {
          return {
            'name': parts[0],
            'phone': parts[1],
            'userId': parts[2],
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _showCotisationSelection(Map<String, dynamic> userData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Enregistrer un paiement',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF4F46E5),
                    child: Text(
                      userData['name'][0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          userData['phone'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Choisir la cotisation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            
            ..._availableCotisations.map((cotisation) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cotisation['color'].withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: cotisation['color'],
                    size: 20,
                  ),
                ),
                title: Text(
                  cotisation['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '${cotisation['montantPersonnel']} FCFA',
                  style: TextStyle(
                    color: cotisation['color'],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmPayment(userData, cotisation);
                },
              ),
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmPayment(Map<String, dynamic> userData, Map<String, dynamic> cotisation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer le paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Utilisateur: ${userData['name']}'),
            Text('Cotisation: ${cotisation['title']}'),
            Text('Montant: ${cotisation['montantPersonnel']} FCFA'),
            const SizedBox(height: 8),
            const Text(
              'Confirmez-vous que cet utilisateur a effectué ce paiement ?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _recordPayment(userData, cotisation);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _recordPayment(Map<String, dynamic> userData, Map<String, dynamic> cotisation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Paiement de ${userData['name']} enregistré avec succès !',
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 3),
      ),
    );

    setState(() {
      _scannedData = null;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _scannedData = null;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}