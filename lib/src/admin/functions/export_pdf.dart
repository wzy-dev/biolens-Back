import 'package:biolensback/src/main/custom_navigation_bar.dart';
import 'package:download/download.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportPdf {
  static List<TextSpan> _getTextSpanChildren(String inputText) {
    // On découpe la chaîne de caractères autour des balises BBCode [b|u|i] ou [/b|u|i] en prenant soint d'inclure la balise dans le split
    RegExp matchesRegString = RegExp("(?=\\[(b|u|i)\\])|(?<=\\[\/(b|u|i)\\])");
    List<String> listWords = inputText.split(matchesRegString).toList();

    // Détecte une balise d'ouverture
    RegExp openReg = RegExp("\\[(b|u|i)\\]");
    // Détecte une balise de fermeture
    RegExp closeReg = RegExp("\\[\/(b|u|i)\\]");
    // Détecte le contenu d'une balise
    RegExp contentReg = RegExp("(?<=\\[(b|u|i)\\])(.*?)(?=\\[\/(b|u|i)\\])");
    // Détecte l'effet d'une balise
    RegExp getEffect = RegExp("(?<=\\[\/?)(.*?)(?=\\])");

    // List des textSpan qui sera retournée
    List<TextSpan> textSpanChildren = [];

    // Pour chaque chaîne de caractère qui a été splitée
    listWords.forEach(
      (input) {
        // Si c'est un texte simple sans balise
        if (!openReg.hasMatch(input) && !closeReg.hasMatch(input)) {
          textSpanChildren.add(
            TextSpan(text: input),
          );
          return;
        }

        // Si c'est dans une balise
        if (contentReg.hasMatch(input)) {
          // On récupère le texte dans la balise
          String text = input.substring(contentReg.firstMatch(input)!.start,
              contentReg.firstMatch(input)!.end);
          // On récupère le nom de l'effet
          String effect = input.substring(getEffect.firstMatch(input)!.start,
              getEffect.firstMatch(input)!.end);

          textSpanChildren.add(
            TextSpan(
                style: TextStyle(
                  fontWeight:
                      (effect == "b" ? FontWeight.bold : FontWeight.normal),
                  decoration: (effect == "u"
                      ? TextDecoration.underline
                      : TextDecoration.none),
                  fontStyle:
                      (effect == "i" ? FontStyle.italic : FontStyle.normal),
                ),
                text: text),
          );
          return;
        }
      },
    );
    return textSpanChildren;
  }

  static HeaderItem exportToPdf(List<Map<String, dynamic>> products) {
    List<pw.Padding> _drawList(List list) {
      List<pw.Padding> result = [];
      list.forEach(
        (element) => result.add(
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            child: RichText(
              text: TextSpan(
                text: "• ",
                children: _getTextSpanChildren(element),
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      );
      return result;
    }

    Future<Stream<int>> _exportAction(List<Map<String, dynamic>?> docs) async {
      pw.Font base = await PdfGoogleFonts.robotoRegular();
      pw.Font bold = await PdfGoogleFonts.robotoBold();
      pw.Font italic = await PdfGoogleFonts.robotoMediumItalic();

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
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    "${product["names"]["category"]} > ${product["names"]["subCategory"]}"
                        .toLowerCase(),
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

      return stream;
    }

    return HeaderItem(
      label: "Télécharger la base de données",
      action: () {
        _exportAction(products).then((value) {
          download(value, "biolens_export.pdf");
        });
      },
      webOnly: true,
    );
  }
}
