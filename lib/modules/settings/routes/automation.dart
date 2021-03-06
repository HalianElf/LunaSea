import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import '../../settings.dart';

class SettingsAutomation extends StatefulWidget {
    static const ROUTE_NAME = '/settings/automation';

    @override
    State<SettingsAutomation> createState() => _State();
}

class _State extends State<SettingsAutomation> {
    final List<String> _tabTitles = [
        'Lidarr',
        'Radarr',
        'Sonarr',
    ];

    final List<Widget> _tabChildren = [
        SettingsAutomationLidarr(),
        SettingsAutomationRadarr(),
        SettingsAutomationSonarr(),
    ];

    @override
    Widget build(BuildContext context) => DefaultTabController(
        length: _tabTitles.length,
        child: Scaffold(
            appBar: _appBar,
            body: _body,
        ),
    );

    Widget get _appBar => LSAppBarTabs(
        title: 'Settings',
        tabTitles: _tabTitles,
    );

    Widget get _body => TabBarView(children: _tabChildren);
}
