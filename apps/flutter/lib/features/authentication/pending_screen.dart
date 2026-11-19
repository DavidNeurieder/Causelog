import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_state.dart';

class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionControllerProvider);
    final name = state is AuthUnapproved ? state.user.displayName : '';
    return Scaffold(
      appBar: AppBar(title: const Text('Pending approval')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hourglass_top, size: 48),
              const SizedBox(height: 16),
              Text(
                'Account pending approval',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (name.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Signed in as $name'),
              ],
              const SizedBox(height: 12),
              const Text(
                'An administrator must approve your account before you can access projects.',
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                children: [
                  FilledButton.tonal(
                    onPressed: () => ref
                        .read(sessionControllerProvider.notifier)
                        .refreshSession(),
                    child: const Text('Check again'),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.read(sessionControllerProvider.notifier).logout(),
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
