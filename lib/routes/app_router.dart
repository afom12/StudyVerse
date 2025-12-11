import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/notes/presentation/screens/notes_list_screen.dart';
import '../features/notes/presentation/screens/note_editor_screen.dart';
import '../features/flashcards/presentation/screens/decks_list_screen.dart';
import '../features/flashcards/presentation/screens/deck_detail_screen.dart';
import '../features/flashcards/presentation/screens/review_screen.dart';
import '../features/groups/presentation/screens/groups_list_screen.dart';
import '../features/groups/presentation/screens/group_detail_screen.dart';
import '../features/planner/presentation/screens/planner_screen.dart';
import '../features/pdf/presentation/screens/pdf_viewer_screen.dart';
import '../features/courses/presentation/screens/courses_list_screen.dart';
import '../features/courses/presentation/screens/course_detail_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/courses',
        builder: (context, state) => const CoursesListScreen(),
      ),
      GoRoute(
        path: '/courses/:courseId',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return CourseDetailScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/notes',
        builder: (context, state) {
          final courseId = state.uri.queryParameters['courseId'];
          return NotesListScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/notes/:noteId/edit',
        builder: (context, state) {
          final noteId = state.pathParameters['noteId']!;
          final courseId = state.uri.queryParameters['courseId'];
          return NoteEditorScreen(
            noteId: noteId,
            courseId: courseId,
          );
        },
      ),
      GoRoute(
        path: '/notes/new',
        builder: (context, state) {
          final courseId = state.uri.queryParameters['courseId'];
          return NoteEditorScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/flashcards',
        builder: (context, state) {
          final courseId = state.uri.queryParameters['courseId'];
          return DecksListScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/flashcards/decks/:deckId',
        builder: (context, state) {
          final deckId = state.pathParameters['deckId']!;
          return DeckDetailScreen(deckId: deckId);
        },
      ),
      GoRoute(
        path: '/flashcards/review/:deckId',
        builder: (context, state) {
          final deckId = state.pathParameters['deckId']!;
          return ReviewScreen(deckId: deckId);
        },
      ),
      GoRoute(
        path: '/groups',
        builder: (context, state) => const GroupsListScreen(),
      ),
      GoRoute(
        path: '/groups/:groupId',
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return GroupDetailScreen(groupId: groupId);
        },
      ),
      GoRoute(
        path: '/planner',
        builder: (context, state) => const PlannerScreen(),
      ),
      GoRoute(
        path: '/pdf/:pdfId',
        builder: (context, state) {
          final pdfId = state.pathParameters['pdfId']!;
          return PDFViewerScreen(pdfId: pdfId);
        },
      ),
    ],
  );
}

