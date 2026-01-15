final versionFileConfig = 1;

class AppConfig {
  final bool isCalcGatewayEnabled;
  final bool darkMode;
  final int versionFileConfig;

  AppConfig({
    this.versionFileConfig = 1,
    this.isCalcGatewayEnabled = true,
    this.darkMode = true,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      versionFileConfig: json['versionFileConfig'] ?? 0,
      isCalcGatewayEnabled: json['isCalcGatewayEnabled'] ?? true,
      darkMode: json['darkMode'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'versionFileConfig': versionFileConfig,
    'isCalcGatewayEnabled': isCalcGatewayEnabled,
    'darkMode': darkMode,
  };
}
