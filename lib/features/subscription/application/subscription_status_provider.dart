/// Fetches live subscription status from Enjoy API.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:enjoy_player/core/release/app_variant.dart';
import 'package:enjoy_player/features/auth/domain/user_profile.dart';
import 'package:enjoy_player/features/subscription/data/subscription_repository.dart';
import 'package:enjoy_player/features/subscription/domain/subscription_status.dart';

part 'subscription_status_provider.g.dart';

@Riverpod(keepAlive: true)
Future<SubscriptionStatus> subscriptionStatus(Ref ref) async {
  // No account server in a local build — report the free tier directly.
  if (kLocalOnlyBuild) {
    return const SubscriptionStatus(
      subscriptionActive: false,
      subscriptionTier: SubscriptionTier.free,
    );
  }
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getStatus();
}
