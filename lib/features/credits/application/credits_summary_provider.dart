/// Worker credits wallet summary (daily + permanent).
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:enjoy_player/core/release/app_variant.dart';
import 'package:enjoy_player/data/api/services/ai/ai_api_providers.dart';
import 'package:enjoy_player/features/credits/domain/credits_summary.dart';

part 'credits_summary_provider.g.dart';

@Riverpod(keepAlive: false)
Future<CreditsSummary> creditsSummary(Ref ref) {
  // Local builds bill the user's own AI provider, so there is no Enjoy
  // wallet to read.
  if (kLocalOnlyBuild) {
    return Future.value(
      const CreditsSummary(
        tier: 'free',
        dailyUsed: 0,
        dailyLimit: 0,
        dailyRemaining: 0,
        permanentAvailable: 0,
        resetAt: 0,
      ),
    );
  }
  return ref.watch(creditsApiProvider).getSummary();
}
