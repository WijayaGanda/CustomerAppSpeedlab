import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfHelper {
  static Future<void> generateAndDownloadInvoice({
    required String bookingId,
    required String customerName,
    required String status,
    required int totalAmount,
    required String date,
    required List<String> servicesName, // ✅ Ganti tipe data jadi String
    required List<int> servicesPrice, // ✅ Ganti tipe data jadi int
    List<Map<String, dynamic>>? spareParts,
    int? serviceHistoryTotalPrice,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- HEADER INVOICE --- (Tidak diubah, tetap sama)
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
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                color: PdfColors.grey200,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Deskripsi Layanan",
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
                child: pw.Column(
                  children: List.generate(servicesName.length, (index) {
                    final namaLayanan = servicesName[index];
                    final hargaLayanan =
                        servicesPrice.length > index ? servicesPrice[index] : 0;

                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(
                        bottom: 12,
                      ), // Kasih jarak antar layanan lebih lebar
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            // ✅ HAPUS "- " karena bullet point sudah disetel di controller
                            // ✅ TAMBAH lineSpacing agar baris Varian & Addons tidak nempel ke atasnya
                            child: pw.Text(
                              namaLayanan,
                              style: const pw.TextStyle(lineSpacing: 2.5),
                            ),
                          ),
                          pw.Text(
                            "Rp ${hargaLayanan.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              pw.Divider(),

              // --- SPARE PARTS SECTION --- (Tidak diubah, tetap sama)
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
                                        style: const pw.TextStyle(fontSize: 10),
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
                pw.SizedBox(height: 10),
              ],

              pw.Spacer(),

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
              pw.SizedBox(height: 20),

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

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Invoice_Speedlab_$bookingId.pdf',
    );
  }
}
