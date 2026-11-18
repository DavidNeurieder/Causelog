import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_state.dart';
import '../features/authentication/login_screen.dart';
import '../features/authentication/pending_screen.dart';
import '../features/authentication/register_screen.dart';
import '../features/authentication/server_config_screen.dart';
import '../features/authentication/setup_screen.dart';
import '../features/authentication/splash_screen.dart';
import '../features/decisions/decision_detail_screen.dart';
import '../features/decisions/decisions_screen.dart';
import '../features/experiments/experiment_detail_screen.dart';
import '../features/experiments/experiments_screen.dart';
import '../features/goals/goal_detail_screen.dart';
import '../features/goals/goals_screen.dart';
import '../features/notes/note_detail_screen.dart';
import '../features/notes/notes_screen.dart';
import '../features/projects/project_detail_screen.dart';
import '../features/projects/projects_screen.dart';
import 'providers.dart';

class RouterRefresh extends ChangeNotifier {
  RouterRefresh(Ref ref) {
    ref.listen<AuthState>(sessionControllerProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(sessionControllerProvider);
      final loc = state.matchedLocation;

      if (auth is AuthUnknown) {
        return loc == '/' ? null : '/';
      }
      if (auth is AuthNeedsServer) {
        return loc == '/connect' ? null : '/connect';
      }
      if (auth is AuthNeedsSetup) {
        return loc == '/setup' ? null : '/setup';
      }
      if (auth is AuthUnauthenticated) {
        return (loc == '/login' || loc == '/register') ? null : '/login';
      }
      if (auth is AuthUnapproved) {
        return loc == '/pending' ? null : '/pending';
      }
      if (auth is AuthAuthenticated) {
        if (loc == '/' ||
            loc == '/connect' ||
            loc == '/setup' ||
            loc == '/login' ||
            loc == '/register' ||
            loc == '/pending') {
          return '/projects';
        }
        return null;
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/connect', builder: (context, state) => const ServerConfigScreen()),
      GoRoute(path: '/setup', builder: (context, state) => const SetupScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/pending', builder: (context, state) => const PendingApprovalScreen()),
      GoRoute(
        path: '/projects',
        builder: (context, state) => const ProjectsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                ProjectDetailScreen(id: state.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'goals',
                builder: (context, state) =>
                    GoalsScreen(projectId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: ':goalId',
                    builder: (context, state) => GoalDetailScreen(
                      projectId: state.pathParameters['id']!,
                      goalId: state.pathParameters['goalId']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'decisions',
                builder: (context, state) =>
                    DecisionsScreen(projectId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: ':decisionId',
                    builder: (context, state) => DecisionDetailScreen(
                      projectId: state.pathParameters['id']!,
                      decisionId: state.pathParameters['decisionId']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'experiments',
                builder: (context, state) =>
                    ExperimentsScreen(projectId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: ':experimentId',
                    builder: (context, state) => ExperimentDetailScreen(
                      projectId: state.pathParameters['id']!,
                      experimentId: state.pathParameters['experimentId']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'notes',
                builder: (context, state) =>
                    NotesScreen(projectId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: ':noteId',
                    builder: (context, state) => NoteDetailScreen(
                      projectId: state.pathParameters['id']!,
                      noteId: state.pathParameters['noteId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
