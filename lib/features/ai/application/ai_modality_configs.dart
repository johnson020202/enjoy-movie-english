import 'package:flutter/foundation.dart';

import 'package:enjoy_player/core/release/app_variant.dart';
import 'package:enjoy_player/features/ai/domain/ai_provider.dart';
import 'package:enjoy_player/features/ai/domain/ai_service_config.dart';
import 'package:enjoy_player/features/ai/domain/llm_api_spec.dart';
import 'package:enjoy_player/features/ai/domain/modality_byok_config.dart';
import 'package:enjoy_player/features/ai/domain/speech_byok_kind.dart';

/// Per-modality [AIServiceConfig]. Replace via [AiModalityConfigs] override later.
@immutable
final class AiModalityConfigs {
  const AiModalityConfigs({
    required this.asr,
    required this.tts,
    required this.llm,
    required this.translation,
    required this.dictionary,
    required this.assessment,
  });

  /// Enjoy-cloud defaults (upstream behavior).
  static const AiModalityConfigs enjoyDefaults = AiModalityConfigs(
    asr: AIServiceConfig(provider: AIProvider.enjoy),
    tts: AIServiceConfig(provider: AIProvider.enjoy),
    llm: AIServiceConfig(provider: AIProvider.enjoy),
    translation: AIServiceConfig(provider: AIProvider.enjoy),
    dictionary: AIServiceConfig(provider: AIProvider.enjoy),
    assessment: AIServiceConfig(provider: AIProvider.enjoy),
  );

  /// BYOK setup prefilled with the own relay, with no key stored yet.
  ///
  /// The LLM-backed surfaces (translation, dictionary, contextual lookup) all
  /// route through the same OpenAI-compatible endpoint. Speech surfaces need
  /// an Azure key, which cannot be prefilled — until one is entered they
  /// surface the usual "provider not configured" message.
  static const AiModalityConfigs byokDefaults = AiModalityConfigs(
    llm: AIServiceConfig(
      provider: AIProvider.byok,
      llmByok: LlmByokConfig(
        apiSpec: LlmApiSpec.openAiCompatible,
        baseUrl: kDefaultByokBaseUrl,
        model: kDefaultByokModel,
      ),
    ),
    translation: AIServiceConfig(
      provider: AIProvider.byok,
      llmByok: LlmByokConfig(
        apiSpec: LlmApiSpec.openAiCompatible,
        baseUrl: kDefaultByokBaseUrl,
        model: kDefaultByokModel,
      ),
    ),
    dictionary: AIServiceConfig(
      provider: AIProvider.byok,
      llmByok: LlmByokConfig(
        apiSpec: LlmApiSpec.openAiCompatible,
        baseUrl: kDefaultByokBaseUrl,
        model: kDefaultByokModel,
      ),
    ),
    asr: AIServiceConfig(
      provider: AIProvider.byok,
      speechByok: SpeechByokConfig(
        kind: SpeechByokKind.openAiCompatible,
        baseUrl: kDefaultByokBaseUrl,
        model: 'whisper-1',
      ),
    ),
    tts: AIServiceConfig(
      provider: AIProvider.byok,
      speechByok: SpeechByokConfig(
        kind: SpeechByokKind.openAiCompatible,
        baseUrl: kDefaultByokBaseUrl,
        model: 'tts-1',
      ),
    ),
    assessment: AIServiceConfig(provider: AIProvider.byok),
  );

  /// Defaults for this build: BYOK on a local-only build, Enjoy upstream.
  static const AiModalityConfigs defaults = kLocalOnlyBuild
      ? byokDefaults
      : enjoyDefaults;

  final AIServiceConfig asr;
  final AIServiceConfig tts;
  final AIServiceConfig llm;
  final AIServiceConfig translation;
  final AIServiceConfig dictionary;
  final AIServiceConfig assessment;
}
