import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/pdf_model.dart';
import '../../data/repositories/pdf_repository.dart';

final pdfRepositoryProvider = Provider<PDFRepository>((ref) {
  final repo = PDFRepository();
  repo.init();
  return repo;
});

final pdfsProvider = StreamProvider.family<List<PDFModel>, String?>((ref, courseId) {
  return ref.watch(pdfRepositoryProvider).watchPDFs(courseId: courseId);
});

final pdfProvider = FutureProvider.family<PDFModel?, String>((ref, pdfId) async {
  return await ref.watch(pdfRepositoryProvider).getPDF(pdfId);
});

