import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../providers/pdf_provider.dart';

class PDFViewerScreen extends ConsumerWidget {
  final String pdfId;

  const PDFViewerScreen({super.key, required this.pdfId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pdfAsync = ref.watch(pdfProvider(pdfId));

    return pdfAsync.when(
      data: (pdf) {
        if (pdf == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('PDF Not Found')),
            body: const Center(child: Text('PDF not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(pdf.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.highlight_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Highlight mode - Coming soon')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_outline),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bookmark - Coming soon')),
                  );
                },
              ),
            ],
          ),
          body: SfPdfViewer.network(
            pdf.storageUrl,
            onDocumentLoadFailed: (details) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to load PDF: ${details.error}')),
              );
            },
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading PDF...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $err')),
      ),
    );
  }
}

