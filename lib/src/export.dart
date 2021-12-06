import 'package:download/download.dart';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class Export extends StatelessWidget {
  const Export({Key? key, required this.products}) : super(key: key);

  final List<Map<String, dynamic>> products;

  List<pw.Padding> _drawList(List list) {
    List<pw.Padding> result = [];
    list.forEach(
      (element) => result.add(
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Text("• $element"),
        ),
      ),
    );
    return result;
  }

  Future<CupertinoButton> _exportAction(
      BuildContext context, List<Map<String, dynamic>?> docs) async {
    pw.Font base = pw.Font.ttf(await rootBundle.load("arial.ttf"));
    pw.Font bold = pw.Font.ttf(await rootBundle.load("arial-Bold.ttf"));
    pw.Font italic = pw.Font.ttf(await rootBundle.load("arial-Italic.ttf"));

    pw.ThemeData myTheme =
        pw.ThemeData.withFont(base: base, bold: bold, italic: italic);

    pw.Document pdf = pw.Document(theme: myTheme);

    docs.forEach(
      (Map<String, dynamic>? product) {
        List<pw.Padding> indications =
            _drawList(product!["names"]["indications"]);

        List<pw.Padding> precautions = _drawList(product["precautions"]);

        List<pw.Padding> ingredients = _drawList(product["ingredients"]);

        List<pw.Padding> cookbook = _drawList(product["cookbook"]);

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      product["name"],
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 20,
                          color: PdfColor.fromHex("3768b4")),
                    ),
                    pw.Text(
                      " ${product["brand"]}",
                      style: pw.TextStyle(
                        fontStyle: pw.FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  "${product["names"]["category"]} > ${product["names"]["subCategory"]}"
                      .toLowerCase(),
                  style: pw.TextStyle(
                    fontSize: 15,
                  ),
                ),
                pw.SizedBox(height: 25),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 5),
                      child: pw.Text(
                        "Indications".toUpperCase(),
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex("3768b4")),
                      ),
                    ),
                    ...indications
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 5),
                      child: pw.Text(
                        "Précautions".toUpperCase(),
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex("3768b4")),
                      ),
                    ),
                    ...precautions
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 5),
                      child: pw.Text(
                        "Composition".toUpperCase(),
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex("3768b4")),
                      ),
                    ),
                    ...ingredients
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 5),
                      child: pw.Text(
                        "Usage".toUpperCase(),
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex("3768b4")),
                      ),
                    ),
                    ...cookbook,
                  ],
                ),
              ];
            },
          ),
        );
      },
    );

    final Uint8List pdfInBytes = await pdf.save();
    final Stream<int> stream = Stream.fromIterable(pdfInBytes.toList());

    return CupertinoButton(
      minSize: 25,
      padding: EdgeInsets.zero,
      onPressed: () => download(stream, "biolens_export.pdf"),
      child: Icon(
        CupertinoIcons.download_circle,
        color: Theme.of(context).primaryColor,
        size: 25,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CupertinoButton>(
      future: _exportAction(context, products),
      builder: (context, snapshotExport) {
        if (snapshotExport.connectionState != ConnectionState.done) {
          return CupertinoActivityIndicator();
        }

        return snapshotExport.data ?? CupertinoActivityIndicator();
      },
    );
  }
}
