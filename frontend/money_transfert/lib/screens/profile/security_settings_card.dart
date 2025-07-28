import 'package:flutter/material.dart';
import '../../widgets/ui/card.dart' as ui;
import '../../widgets/ui/switch.dart' as ui_switch;

class SecuritySetting {
  final String id;
  final String label;
  final String description;
  final bool enabled;

  SecuritySetting({
    required this.id,
    required this.label,
    required this.description,
    required this.enabled,
  });
}

class SecuritySettingsCard extends StatefulWidget {
  final List<SecuritySetting> settings;
  final Function(String, bool)? onSettingChanged;

  const SecuritySettingsCard({
    super.key,
    required this.settings,
    this.onSettingChanged,
  });

  @override
  State<SecuritySettingsCard> createState() => _SecuritySettingsCardState();
}

class _SecuritySettingsCardState extends State<SecuritySettingsCard> {
  late Map<String, bool> _settingsState;

  @override
  void initState() {
    super.initState();
    _settingsState = {
      for (var setting in widget.settings) setting.id: setting.enabled
    };
  }

  void _handleSettingChanged(String id, bool value) {
    setState(() {
      _settingsState[id] = value;
    });
    widget.onSettingChanged?.call(id, value);
  }

  @override
  Widget build(BuildContext context) {
    return ui.CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paramètres de sécurité',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Liste des paramètres de sécurité
          ...widget.settings.map((setting) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                // Informations du paramètre
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        setting.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        setting.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Switch
                ui_switch.CustomSwitch(
                  checked: _settingsState[setting.id] ?? setting.enabled,
                  onChanged: (value) => _handleSettingChanged(setting.id, value),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}
