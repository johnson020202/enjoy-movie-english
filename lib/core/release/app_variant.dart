/// Branding and distribution identity for this build.
library;

/// Product name shown in the UI and the OS app label.
const String kAppProductName = 'Enjoy Movie English';

/// Build variant: this fork runs entirely on-device with no Enjoy account.
///
/// With [kLocalOnlyBuild] set, the app boots into a synthetic local profile
/// instead of the sign-in gate, and every AI capability defaults to BYOK so
/// no request reaches Enjoy's closed-source backend.
const bool kLocalOnlyBuild = true;

/// Identity of the synthetic local profile (also the per-user database key).
const String kLocalProfileId = 'local';

/// Display name for the synthetic local profile.
const String kLocalProfileName = '本地用户';

/// Update feed for this fork (GitHub Pages-free: raw file on the default branch).
const String kAppUpdateManifestUrl =
    'https://raw.githubusercontent.com/johnson020202/enjoy-movie-english/main/'
    'latest.json';

/// Repository the APK releases are published to.
const String kAppRepositoryUrl =
    'https://github.com/johnson020202/enjoy-movie-english';

/// Default OpenAI-compatible endpoint used to prefill BYOK forms.
///
/// The user's own relay; only the base URL ships here — API keys stay in the
/// device keychain, entered from Settings → AI providers.
const String kDefaultByokBaseUrl = 'https://zzz.sub2api.me/v1';

/// Model prefilled for the LLM/translation/dictionary BYOK forms.
const String kDefaultByokModel = 'gpt-4o-mini';
