import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfHelper {
  // Fungsi utama untuk membuat dan mengunduh/share Invoice
  static Future<void> generateAndDownloadInvoice({
    required String bookingId,
    required String customerName,
    required String status,
    required int totalAmount,
    required String date,
    required List<dynamic> servicesName,
    required List<dynamic> servicesPrice,
    List<Map<String, dynamic>>? spareParts,
    int? serviceHistoryTotalPrice,
  }) async {
    // 1. Buat dokumen PDF kosong
    final pdf = pw.Document();

    // 2. Gambar isi halamannya
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- HEADER INVOICE ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "SPEEDLAB BENGKEL",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    "INVOICE",
                    style: pw.TextStyle(
                      fontSize: 24,
                      color: PdfColors.blueGrey,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // --- INFO PELANGGAN & BOOKING ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Ditagihkan Kepada:",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(customerName),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "ID Booking: $bookingId",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text("Tanggal: $date"),
                      pw.Text(
                        "Status: $status",
                        style: pw.TextStyle(
                          color:
                              status == 'Terverifikasi'
                                  ? PdfColors.green
                                  : PdfColors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // --- TABEL RINCIAN BIAYA ---
              // (Untuk simpelnya kita pakai format baris, kalau butuh tabel kompleks bisa pakai pw.Table)
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                color: PdfColors.grey200,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Deskripsi",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      "Harga",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Kolom Kiri: Daftar Servis (Looping ke bawah)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children:
                          servicesName.map((servis) {
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(
                                bottom: 4,
                              ), // Jarak antar baris servis
                              child: pw.Text("- ${servis.toString()}"),
                            );
                          }).toList(),
                    ),

                    // Kolom Kanan: Total Harga
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children:
                          servicesPrice.map((price) {
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(
                                bottom: 4,
                              ), // Jarak antar baris servis
                              child: pw.Text(
                                "Rp. ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              pw.Divider(),

              // --- SPARE PARTS SECTION ---
              if (spareParts != null && spareParts.isNotEmpty) ...[
                pw.SizedBox(height: 15),
                pw.Text(
                  "Spare Parts yang Digunakan:",
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  color: PdfColors.grey100,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children:
                        spareParts.map((part) {
                          String partName = part['name'] ?? 'Spare Part';
                          int partPrice = part['price'] ?? 0;
                          int partQty = part['quantity'] ?? 1;
                          int subtotal = partPrice * partQty;

                          return pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 5),
                            child: pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Expanded(
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        "- $partName",
                                        style: pw.TextStyle(fontSize: 10),
                                      ),
                                      pw.Text(
                                        "  Qty: $partQty × Rp ${partPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                                        style: pw.TextStyle(
                                          fontSize: 9,
                                          color: PdfColors.grey700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                pw.Text(
                                  "Rp ${subtotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
                pw.Divider(),
                // pw.SizedBox(height: 10),
                // pw.Container(
                //   alignment: pw.Alignment.centerRight,
                //   child: pw.Column(
                //     crossAxisAlignment: pw.CrossAxisAlignment.end,
                //     children: [
                //       pw.Text(
                //         "Total Pergantian Spareparts:",
                //         style: pw.TextStyle(
                //           fontSize: 11,
                //           color: PdfColors.grey700,
                //         ),
                //       ),
                //       pw.Text(
                //         "Rp ${serviceHistoryTotalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}')}",
                //         style: pw.TextStyle(
                //           fontSize: 14,
                //           fontWeight: pw.FontWeight.bold,
                //           color: PdfColors.blue,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                pw.SizedBox(height: 10),
              ],

              pw.Divider(),
              // --- TOTAL AKHIR ---
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "Total Tagihan: Rp ${(serviceHistoryTotalPrice ?? totalAmount).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.Spacer(),

              // --- FOOTER ---
              pw.Center(
                child: pw.Text(
                  "Terima kasih telah mempercayakan motor Anda di Speedlab!",
                  style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // 3. Simpan dan bagikan PDF-nya (Otomatis memunculkan dialog native OS)
    final bytes = await pdf.save();

    // Perintah ini akan memunculkan menu "Save to Files", "Share to WhatsApp", dll di Android/iOS
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Invoice_Speedlab_$bookingId.pdf',
    );
  }
}
