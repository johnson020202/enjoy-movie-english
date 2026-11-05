/// Synthetic profile used by local-only builds.
library;

import 'package:enjoy_player/core/release/app_variant.dart';
import 'package:enjoy_player/features/auth/domain/auth_state.dart';
import 'package:enjoy_player/features/auth/domain/user_profile.dart';

/// Session state for the on-device profile.
///
/// Local builds have no account server, but most of the app keys its library,
/// preferences and statistics off `AuthSignedIn` (the per-user Drift database
/// is named after `profile.id`). Returning a fixed local profile keeps every
/// downstream provider on its normal code path while nothing is sent to a
/// remote account service.
AuthState localProfileState() {
  return const AuthSignedIn(
    profile: UserProfile(
      id: kLocalProfileId,
      email: '',
      name: kLocalProfileName,
      subscriptionTier: SubscriptionTier.free,
      goal: 30,
    ),
  );
}
