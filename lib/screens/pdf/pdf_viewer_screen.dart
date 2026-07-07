import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../core/app_colors.dart';
import '../../models/pdf_model.dart';

class PdfViewerScreen extends StatefulWidget {
  final PdfModel pdf;
  const PdfViewerScreen({super.key, required this.pdf});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoaded = false;
  PDFViewController? _pdfController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundFor(context),
      appBar: AppBar(
        title: Text(
          widget.pdf.title,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.surfaceFor(context),
        actions: [
          if (_isLoaded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                '$_currentPage / $_totalPages',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondaryFor(context),
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.pdf.filePath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            nightMode: true,
            backgroundColor: AppColors.backgroundFor(context),
            onRender: (pages) {
              setState(() {
                _totalPages = pages ?? 0;
                _isLoaded = true;
              });
            },
            onPageChanged: (page, total) {
              setState(() {
                _currentPage = (page ?? 0) + 1;
                _totalPages = total ?? 0;
              });
            },
            onViewCreated: (controller) {
              _pdfController = controller;
            },
            onError: (error) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: $error')));
            },
          ),
          if (!_isLoaded)
            const Center(
              child: CircularProgressIndicator(color: AppColors.pdfColor),
            ),
        ],
      ),
      bottomNavigationBar: _isLoaded
          ? Container(
              color: AppColors.surfaceFor(context),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: _currentPage > 1
                        ? () => _pdfController?.setPage(_currentPage - 2)
                        : null,
                  ),
                  Text(
                    '$_currentPage of $_totalPages',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondaryFor(context),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: _currentPage < _totalPages
                        ? () => _pdfController?.setPage(_currentPage)
                        : null,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
