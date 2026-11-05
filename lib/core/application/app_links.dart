/// Public URLs for this build of the app.
library;

import 'package:enjoy_player/core/release/app_variant.dart';

/// Canonical repository for this fork.
const String kEnjoyPlayerGitHubUrl = kAppRepositoryUrl;

/// Base URL for release artifacts and update feeds (no trailing slash).
const String kEnjoyPlayerDownloadBaseUrl = '$kAppRepositoryUrl/releases/latest/download';

/// Sparkle / WinSparkle appcast. Desktop builds of this fork are not shipped,
/// so this stays pointed at a path that will never resolve.
const String kEnjoyPlayerAppcastUrl =
    '$kEnjoyPlayerDownloadBaseUrl/appcast.xml';

/// JSON manifest for semver checks and Android sideload APK URLs.
const String kEnjoyPlayerLatestJsonUrl = kAppUpdateManifestUrl;

/// Developer contact details shown in Settings → About for feedback/support.
const String kDeveloperContactEmail = 'zhaoluhang1989@users.noreply.github.com';
const String kDeveloperContactWeChatId = '';
const String kDeveloperContactMixinId = '';
