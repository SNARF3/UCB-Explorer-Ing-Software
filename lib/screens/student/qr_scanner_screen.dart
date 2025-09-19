import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String? scannedCode;
  bool _yaProcesado = false; // <-- bandera para evitar múltiples sumas

  Future<void> _sumarPuntosUsuario(int puntos) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    final userRef = FirebaseFirestore.instance.collection('estudiantes').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final currentPuntos = (snapshot.data()?['puntos'] ?? 0) as int;
      transaction.update(userRef, {'puntos': currentPuntos + puntos});
    });
  }

  void _procesarCodigo(String? code) async {
    if (_yaProcesado) return; // <-- solo permite el primer escaneo
    if (code == null) return;
    setState(() {
      scannedCode = code;
    });

    final regex = RegExp(r'(\d+)\s*pts', caseSensitive: false);
    final match = regex.firstMatch(code);
    if (match != null) {
      final puntos = int.tryParse(match.group(1) ?? '');
      if (puntos != null) {
        _yaProcesado = true; // <-- marca como procesado
        await _sumarPuntosUsuario(puntos);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Ganaste $puntos puntos!'),
            backgroundColor: Colors.green,
          ),
        );
        // Espera un momento para mostrar el mensaje y luego navega al home
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escaner QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.yellow),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  _procesarCodigo(barcode.rawValue);
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              scannedCode ?? 'Escanea un código QR',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}