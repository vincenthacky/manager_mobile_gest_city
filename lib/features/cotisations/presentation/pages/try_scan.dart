// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:jwt_decode/jwt_decode.dart';
// import 'package:encrypt/encrypt.dart' as encrypt_pkg; // pour AES (optionnel)

// class QrScannerPage extends StatefulWidget {
//   const QrScannerPage({Key? key}) : super(key: key);

//   @override
//   State<QrScannerPage> createState() => _QrScannerPageState();
// }

// class _QrScannerPageState extends State<QrScannerPage> {
//   final MobileScannerController cameraController = MobileScannerController();
//   bool isProcessing = false;
//   String? resultText;
//   // Pour AES (optionnel) : fournis clé & iv en hex/base64 selon ton choix
//   final TextEditingController keyController =
//       TextEditingController(); // ex: 32 bytes base64 or hex
//   final TextEditingController ivController =
//       TextEditingController(); // ex: 16 bytes base64 or hex

//   @override
//   void dispose() {
//     cameraController.dispose();
//     keyController.dispose();
//     ivController.dispose();
//     super.dispose();
//   }

//   void _handleScan(String data) async {
//     if (isProcessing) return;
//     setState(() {
//       isProcessing = true;
//       resultText = "Processing...";
//     });

//     // Arrêter la caméra pour éviter multis-captures
//     cameraController.stop();

//     String output = 'Raw: $data\n\n';
//     // 1) Tentative base64 decode
//     try {
//       final decoded = base64.decode(data);
//       final decodedStr = utf8.decode(decoded);
//       output += 'Base64 decoded → $decodedStr\n\n';
//     } catch (_) {
//       output += 'Base64 decode: failed\n\n';
//     }

//     // 2) Tentative JWT parsing (sans vérif signature)
//     try {
//       if (Jwt.isExpired(data) ||
//           Jwt.getExpiryDate(data) != null
//           // || Jwt.getPayload(data).isNotEmpty
//           )
//           {
//         final payload = Jwt.parseJwt(data);
//         output += 'JWT payload → ${payload.toString()}\n\n';
//       }
//       else {
//         // parseJwt lancera si c'est un JWT valide
//         final payload = Jwt.parseJwt(data);
//         output += 'JWT payload → ${payload.toString()}\n\n';
//       }
//     } catch (_) {
//       output += 'JWT parse: not a JWT or failed\n\n';
//     }

//     // 3) AES decryption exemple (optionnel)
//     final keyInput = keyController.text.trim();
//     final ivInput = ivController.text.trim();
//     if (keyInput.isNotEmpty && ivInput.isNotEmpty) {
//       try {
//         // Ici j'essaie base64 -> bytes pour clé & iv. Adapte si tu utilises hex.
//         final keyBytes = base64.decode(keyInput);
//         final ivBytes = base64.decode(ivInput);

//         final key = encrypt_pkg.Key(keyBytes);
//         final iv = encrypt_pkg.IV(ivBytes);
//         final encrypter = encrypt_pkg.Encrypter(
//           encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.cbc),
//         );

//         final encrypted = encrypt_pkg.Encrypted.fromBase64(data);
//         final decrypted = encrypter.decrypt(encrypted, iv: iv);

//         output += 'AES decrypted → $decrypted\n\n';
//       } catch (e) {
//         output += 'AES decrypt: failed (${e.toString()})\n\n';
//       }
//     } else {
//       output += 'AES decrypt: clé/iv non fournies\n\n';
//     }

//     setState(() {
//       resultText = output;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scanner QR / Token'),
//         actions: [
//           // IconButton(
//           //   icon: ValueListenableBuilder(
//           //     valueListenable: cameraController.torchState,
//           //     builder: (context, TorchState state, child) {
//           //       return Icon(state == TorchState.off ? Icons.flash_off : Icons.flash_on);
//           //     },
//           //   ),
//           //   onPressed: () => cameraController.toggleTorch(),
//           // ),
//           IconButton(
//             icon: const Icon(Icons.cameraswitch),
//             onPressed: () => cameraController.switchCamera(),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Zone caméra
//           Expanded(
//             flex: 3,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 MobileScanner(
//                   controller: cameraController,
//                   // allowDuplicates: false,
//                   onDetect: (capture) {
//                     final List<Barcode> barcodes = capture.barcodes;
//                     if (barcodes.isNotEmpty) {
//                       final String raw = barcodes.first.rawValue ?? '';
//                       _handleScan(raw);
//                     }
//                   },
//                 ),
//                 // overlay simple
//                 Align(
//                   alignment: Alignment.topCenter,
//                   child: Container(
//                     margin: const EdgeInsets.all(16),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.black54,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Text(
//                       'Place le QR dans le cadre',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Form clé/iv (optionnel, si token chiffré)
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               children: [
//                 const Text(
//                   'Si token chiffré (AES), fournis clé et IV en base64 :',
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: keyController,
//                   decoration: const InputDecoration(
//                     labelText: 'Clé AES (base64)',
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: ivController,
//                   decoration: const InputDecoration(labelText: 'IV (base64)'),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//                         // relancer la caméra pour rescanner
//                         setState(() {
//                           resultText = null;
//                           isProcessing = false;
//                         });
//                         cameraController.start();
//                       },
//                       child: const Text('Reprendre le scan'),
//                     ),
//                     const SizedBox(width: 12),
//                     ElevatedButton(
//                       onPressed: () {
//                         cameraController.start();
//                         setState(() {
//                           resultText = null;
//                           isProcessing = false;
//                         });
//                       },
//                       child: const Text('Démarrer caméra'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // Résultat
//           Expanded(
//             flex: 2,
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(12),
//               child: resultText == null
//                   ? const Text('Aucun résultat')
//                   : Text(
//                       resultText!,
//                       style: const TextStyle(fontFamily: 'monospace'),
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../../controllers/validate_payment_controller.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({Key? key}) : super(key: key);

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController cameraController = MobileScannerController();
  bool isProcessing = false;
  String? decodedResult;
  final ValidatePaymentController _validateController = ValidatePaymentController();

  void _handleScan(String data) async {
    if (isProcessing) return;
    setState(() => isProcessing = true);

    cameraController.stop();

    // First try to parse as JWT for display purposes, but always attempt
    // to validate the token via backend endpoint.
    try {
      try {
        final payload = Jwt.parseJwt(data);
        final expiry = Jwt.getExpiryDate(data);
        final isExpired = Jwt.isExpired(data);
        decodedResult =
            '''Token décodé :\n${payload.toString()}\n\nExpire le : ${expiry ?? 'N/A'}\nStatus : ${isExpired ? 'Expiré' : 'Valide'}\n''';
      } catch (_) {
        // ignore parsing errors — still proceed to verification
        decodedResult = 'Token brut: $data';
      }

      // Call backend to verify payment using the token in query params
      final resp = await _validateController.verifyQrCode(data);
      if (resp.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resp.message.isNotEmpty
                ? resp.message
                : 'Paiement validé avec succès.'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resp.message.isNotEmpty
                ? resp.message
                : 'Échec de la validation du paiement.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        decodedResult = "Erreur lors de la vérification : $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner un QR')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final barcode = capture.barcodes.first;
                final rawValue = barcode.rawValue;
                if (rawValue != null) {
                  _handleScan(rawValue);
                }
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: decodedResult == null
                  ? const Text('Scanne un QR contenant un token JWT.')
                  : Text(
                      decodedResult!,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              cameraController.start();
              setState(() {
                isProcessing = false;
                decodedResult = null;
              });
            },
            child: const Text('Scanner à nouveau'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    _validateController.dispose();
    super.dispose();
  }
}
