import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/modules/lidarr.dart';

class SettingsAutomationLidarr extends StatefulWidget {
    @override
    State<SettingsAutomationLidarr> createState() => _State();
}

class _State extends State<SettingsAutomationLidarr> {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    ProfileHiveObject _profile = Database.currentProfileObject;

    @override
    Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        body: _body,
    );

    Widget get _body => ValueListenableBuilder(
        valueListenable: Database.profilesBox.listenable(),
        builder: (context, box, widget) {
            return LSListView(
                children: <Widget>[
                    LSCardTile(
                        title: LSTitle(text: 'Enable Lidarr'),
                        subtitle: null,
                        trailing: Switch(
                            value: _profile.lidarrEnabled ?? false,
                            onChanged: (value) {
                                _profile.lidarrEnabled = value;
                                _profile.save();
                            },
                        ),
                    ),
                    LSCardTile(
                        title: LSTitle(text: 'Host'),
                        subtitle: LSSubtitle(
                            text: _profile.lidarrHost == null || _profile.lidarrHost == ''
                                ? 'Not Set'
                                : _profile.lidarrHost
                        ),
                        trailing: LSIconButton(icon: Icons.arrow_forward_ios),
                        onTap: _changeHost,
                    ),
                    LSCardTile(
                        title: LSTitle(text: 'API Key'),
                        subtitle: LSSubtitle(
                            text: _profile.lidarrKey == null || _profile.lidarrKey == ''
                                ? 'Not Set'
                                : '••••••••••••'
                        ),
                        trailing: LSIconButton(icon: Icons.arrow_forward_ios),
                        onTap: _changeKey,
                    ),
                    LSDivider(),
                    LSButton(
                        text: 'Test Connection',
                        onTap: _testConnection,
                    ),
                ],
            );
        },
    );

    Future<void> _changeHost() async {
        List<dynamic> _values = await LSDialogSystem.editText(context, 'Lidarr Host', prefill: _profile.lidarrHost ?? '', showHostHint: true);
        if(_values[0]) {
            _profile.lidarrHost = _values[1];
            _profile.save();
        }
    }

    Future<void> _changeKey() async {
        List<dynamic> _values = await LSDialogSystem.editText(context, 'Lidarr API Key', prefill: _profile.lidarrKey ?? '');
        if(_values[0]) {
            _profile.lidarrKey = _values[1];
            _profile.save();
        }
    }

    Future<void> _testConnection() async => await LidarrAPI.from(_profile).testConnection()
        ? LSSnackBar(context: context, title: 'Connected Successfully', message: 'Lidarr is ready to use with LunaSea', type: SNACKBAR_TYPE.success)
        : LSSnackBar(context: context, title: 'Connection Test Failed', message: Constants.CHECK_LOGS_MESSAGE, type: SNACKBAR_TYPE.failure);
}
