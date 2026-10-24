import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../shop/data/shop_repository.dart';
import 'sales_transaction_model.dart';

class PdfReportGenerator {
  static Future<void> generateAndDownloadPdf({
    required List<SalesTransaction> transactions,
    required String period,
  }) async {
    final pdf = pw.Document();
    final shop = ShopRepository.currentShop();
    final shopName = shop?['name'] ?? 'Mitra POS';
    final shopDetails = '${shop?['businessType'] ?? 'Usaha UMKM'} • ${shop?['city'] ?? ''}, ${shop?['province'] ?? ''}';
    
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final now = DateTime.now();
    final printDateStr = '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final totalOmset = transactions.fold<int>(0, (sum, t) => sum + t.grandTotal);
    final totalTrx = transactions.length;
    final totalItemsSold = transactions.fold<int>(
      0,
      (sum, t) => sum + t.items.fold<int>(0, (iSum, item) => iSum + item.quantity),
    );

    final primaryColor = PdfColor.fromHex('0F5B67');
    final secondaryColor = PdfColor.fromHex('45A1B2');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header Section
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'LAPORAN REKAPAN PENJUALAN',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      shopName,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      shopDetails,
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: secondaryColor,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'PERIODE: $period',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Tanggal Cetak: $printDateStr',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1.5, color: primaryColor),
            pw.SizedBox(height: 16),

            // Metrics Summary Table
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _pdfStatBox('TOTAL OMSET', currencyFormatter.format(totalOmset), primaryColor),
                  _pdfStatBox('TOTAL TRANSAKSI', '$totalTrx Transaksi', primaryColor),
                  _pdfStatBox('PRODUK TERJUAL', '$totalItemsSold Pcs', primaryColor),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Transactions Table Title
            pw.Text(
              'Detail Rincian Transaksi',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: primaryColor),
            ),
            pw.SizedBox(height: 8),

            // Transactions Table
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 10,
              ),
              headerDecoration: pw.BoxDecoration(color: primaryColor),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              headers: ['No', 'ID Transaksi', 'Waktu', 'Pembayaran', 'Rincian Item', 'Total (Rp)'],
              data: List.generate(transactions.length, (index) {
                final trx = transactions[index];
                final dateStr = '${trx.timestamp.day}/${trx.timestamp.month}/${trx.timestamp.year} ${trx.timestamp.hour.toString().padLeft(2, '0')}:${trx.timestamp.minute.toString().padLeft(2, '0')}';
                final itemsSummary = trx.items.map((i) => '${i.productName} x${i.quantity}').join(', ');
                return [
                  '${index + 1}',
                  trx.id,
                  dateStr,
                  trx.paymentMethod,
                  itemsSummary,
                  currencyFormatter.format(trx.grandTotal),
                ];
              }),
            ),
            pw.SizedBox(height: 24),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Dicetak otomatis oleh Sistem Mitra Digital POS',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Trigger Download PDF / Print Dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_Penjualan_$shopName.pdf',
    );
  }

  static pw.Widget _pdfStatBox(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
