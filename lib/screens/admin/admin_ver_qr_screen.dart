import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AdminVerQRScreen extends StatefulWidget {
  const AdminVerQRScreen({super.key});

  @override
  State<AdminVerQRScreen> createState() => _AdminVerQRScreenState();
}

class _AdminVerQRScreenState extends State<AdminVerQRScreen> {
  List<Map<String, dynamic>> qrList = [];
  bool loading = true;
  Map<String, dynamic>? selectedQR;

  @override
  void initState() {
    super.initState();
    _loadQRsFromFirebase();
  }

  Future<void> _loadQRsFromFirebase() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('qr_data').get();
      setState(() {
        qrList = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
        loading = false;
      });
    } catch (e) {
      print('❌ Error cargando QRs: $e');
      setState(() {
        loading = false;
      });
    }
  }

  Future<Uint8List?> _generarQRBytes(String data) async {
    try {
      final qrPainter = QrPainter(
        data: data,
        version: QrVersions.auto,
        gapless: true,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
      );
      final image = await qrPainter.toImage(300);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('❌ Error generando QR: $e');
      return null;
    }
  }

  Widget _buildQRPreview() {
    if (selectedQR == null) {
      return const Text(
        'Selecciona un QR para generar el código.',
        style: TextStyle(color: Colors.white),
      );
    }

    return FutureBuilder<Uint8List?>(
      future: _generarQRBytes(selectedQR!['qr']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: Color(0xFFFFD700));
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Text(
            'Error al generar el QR.',
            style: TextStyle(color: Colors.red),
          );
        }

        return Column(
          children: [
            Image.memory(snapshot.data!, height: 200, fit: BoxFit.contain),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes agregar la lógica para descargar el QR si es necesario
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
              ),
              child: const Text(
                'Descargar QR',
                style: TextStyle(color: Color(0xFF004077)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004077),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Ver y Generar QRs',
          style: TextStyle(color: Color(0xFFFFD700)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: qrList.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final item = qrList[index];

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(item['descripcion'] ?? 'Sin descripción'),
                          subtitle: Text(item['qr'] ?? 'Sin contenido'),
                          onTap: () {
                            setState(() {
                              selectedQR = item;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const Divider(color: Colors.white),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildQRPreview(),
                ),
              ],
            ),
    );
  }
}
