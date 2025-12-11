import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import '../../../../core/models/pdf_model.dart';
import '../../../../services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class PDFRepository {
  static const String _boxName = 'pdfs';
  Box<Map>? _box;

  Future<void> init() async {
    if (_box == null) {
      _box = await Hive.openBox<Map>(_boxName);
    }
  }

  String? get _userId {
    try {
      return FirebaseService.currentUser?.uid;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveToLocal(PDFModel pdf) async {
    await init();
    await _box!.put(pdf.id, pdf.toJson());
  }

  List<PDFModel> _getFromLocal({String? courseId}) {
    if (_box == null) return [];
    return _box!.values
        .map((json) => PDFModel.fromJson(Map<String, dynamic>.from(json)))
        .where((pdf) {
          if (pdf.uploadedBy != _userId) return false;
          if (courseId != null && pdf.courseId != courseId) return false;
          return true;
        })
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _saveToCloud(PDFModel pdf) async {
    if (!FirebaseService.isInitialized || _userId == null) return;
    try {
      await FirebaseService.firestore
          .collection('pdfs')
          .doc(pdf.id)
          .set(pdf.toJson());
    } catch (e) {
      print('Error saving PDF to cloud: $e');
    }
  }

  Stream<List<PDFModel>> watchPDFs({String? courseId}) {
    if (!FirebaseService.isInitialized || _userId == null) {
      return Stream.value(_getFromLocal(courseId: courseId));
    }

    try {
      Query query = FirebaseService.firestore
          .collection('pdfs')
          .where('uploadedBy', isEqualTo: _userId);
      
      if (courseId != null) {
        query = query.where('courseId', isEqualTo: courseId);
      }
      
      return query
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        final pdfs = snapshot.docs
            .map((doc) => PDFModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
        
        for (final pdf in pdfs) {
          _saveToLocal(pdf);
        }
        
        return pdfs;
      });
    } catch (e) {
      print('Error watching PDFs: $e');
      return Stream.value(_getFromLocal(courseId: courseId));
    }
  }

  Future<PDFModel> uploadPDF({
    required String courseId,
    required String title,
    required File file,
  }) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    if (!FirebaseService.isInitialized) {
      throw Exception('Firebase not initialized');
    }

    try {
      // Upload to Firebase Storage
      final storageRef = FirebaseService.storage
          .ref()
          .child('pdfs')
          .child('${const Uuid().v4()}.pdf');
      
      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      // Create PDF model
      final pdf = PDFModel(
        id: const Uuid().v4(),
        courseId: courseId,
        title: title,
        storageUrl: downloadUrl,
        uploadedBy: _userId!,
        createdAt: DateTime.now(),
      );

      await _saveToLocal(pdf);
      await _saveToCloud(pdf);

      return pdf;
    } catch (e) {
      print('Error uploading PDF: $e');
      rethrow;
    }
  }

  Future<void> addAnnotation(String pdfId, PDFAnnotation annotation) async {
    final pdf = await getPDF(pdfId);
    if (pdf == null) return;

    final updatedAnnotations = [...pdf.annotations, annotation];
    final updatedPDF = PDFModel(
      id: pdf.id,
      courseId: pdf.courseId,
      title: pdf.title,
      storageUrl: pdf.storageUrl,
      uploadedBy: pdf.uploadedBy,
      annotations: updatedAnnotations,
      createdAt: pdf.createdAt,
    );

    await _saveToLocal(updatedPDF);
    await _saveToCloud(updatedPDF);
  }

  Future<PDFModel?> getPDF(String pdfId) async {
    if (!FirebaseService.isInitialized || _userId == null) {
      await init();
      final json = _box!.get(pdfId);
      if (json != null) {
        return PDFModel.fromJson(Map<String, dynamic>.from(json));
      }
      return null;
    }

    try {
      final doc = await FirebaseService.firestore
          .collection('pdfs')
          .doc(pdfId)
          .get();
      
      if (doc.exists) {
        final pdf = PDFModel.fromJson(doc.data()! as Map<String, dynamic>);
        await _saveToLocal(pdf);
        return pdf;
      }
      return null;
    } catch (e) {
      print('Error getting PDF: $e');
      await init();
      final json = _box!.get(pdfId);
      if (json != null) {
        return PDFModel.fromJson(Map<String, dynamic>.from(json));
      }
      return null;
    }
  }

  Future<void> deletePDF(String pdfId) async {
    await init();
    await _box!.delete(pdfId);
    
    if (FirebaseService.isInitialized && _userId != null) {
      try {
        await FirebaseService.firestore.collection('pdfs').doc(pdfId).delete();
      } catch (e) {
        print('Error deleting PDF from cloud: $e');
      }
    }
  }
}

