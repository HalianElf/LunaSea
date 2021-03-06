import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lunasea/core.dart';
import '../../sonarr.dart';

class SonarrSearchDetailsArguments {
    SonarrReleaseData data;

    SonarrSearchDetailsArguments({
        @required this.data,
    });
}

class SonarrSearchDetails extends StatefulWidget {
    static const ROUTE_NAME = '/sonarr/search/details';

    @override
    State<SonarrSearchDetails> createState() => _State();
}

class _State extends State<SonarrSearchDetails> {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    SonarrSearchDetailsArguments _arguments;

    @override
    void initState() {
        super.initState();
        SchedulerBinding.instance.scheduleFrameCallback((_) {
            setState(() => _arguments = ModalRoute.of(context).settings.arguments);
        });
    }

    @override
    Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        appBar: _appBar,
        body: _body,
    );

    Widget get _appBar => _arguments == null
        ? null
        : LSAppBar(
            title: _arguments.data.title,
            actions: [
                LSIconButton(
                    icon: Icons.link,
                    onPressed: () async {
                        _arguments.data.infoUrl != null && _arguments.data.infoUrl != ''
                            ? await _arguments.data.infoUrl.lsLinks_OpenLink()
                            : LSSnackBar(
                                context: context,
                                title: 'Information URL',
                                message: 'No information URL is available',
                            );
                    },
                ),
            ]
        );

    Widget get _body => _arguments == null
        ? null
        : LSListView(
            children: <Widget>[
                LSCardTile(
                    title: LSTitle(text: 'Release Title'),
                    subtitle: LSSubtitle(text: _arguments.data.title),
                    trailing: LSIconButton(icon: Icons.arrow_forward_ios),
                    onTap: () async => LSDialogSystem.textPreview(context, 'Release Title', _arguments.data.title),
                ),
                LSContainerRow(
                    children: <Widget>[
                        Expanded(
                            child: LSCardTile(
                                title: LSTitle(text: 'Protocol', centerText: true),
                                subtitle: LSSubtitle(text: _arguments.data.protocol.lsLanguage_Capitalize(), centerText: true),
                                reducedMargin: true,
                            ),
                        ),
                        Expanded(
                            child: LSCardTile(
                                title: LSTitle(text: 'Indexer', centerText: true),
                                subtitle: LSSubtitle(text: _arguments.data.indexer, centerText: true),
                                reducedMargin: true,
                            ),
                        ),
                    ],
                ),
                LSContainerRow(
                    children: <Widget>[
                        Expanded(
                            child: LSCardTile(
                                title: LSTitle(text: 'Age', centerText: true),
                                subtitle: LSSubtitle(text: _arguments.data.ageHours.lsTime_releaseAgeString(), centerText: true),
                                reducedMargin: true,
                            ),
                        ),
                        Expanded(
                            child: LSCardTile(
                                title: LSTitle(text: 'Size', centerText: true),
                                subtitle: LSSubtitle(text: _arguments.data.size.lsBytes_BytesToString(), centerText: true),
                                reducedMargin: true,
                            ),
                        ),
                    ],
                ),
                if(_arguments.data.isTorrent) LSContainerRow(
                    children: <Widget>[
                        Expanded(
                            child: LSCardTile(
                                title: LSTitle(text: 'Seeders', centerText: true),
                                subtitle: LSSubtitle(
                                    text: _arguments.data.seeders == 1
                                        ? '${_arguments.data.seeders} Seeder'
                                        : '${_arguments.data.seeders} Seeders',
                                    centerText: true,
                                ),
                                reducedMargin: true,
                            ),
                        ),
                        Expanded(
                            child: LSCardTile(
                                title: LSTitle(text: 'Leechers', centerText: true),
                                subtitle: LSSubtitle(
                                    text: _arguments.data.leechers == 1
                                        ? '${_arguments.data.leechers} Leecher'
                                        : '${_arguments.data.leechers} Leechers',
                                    centerText: true,
                                ),
                                reducedMargin: true,
                            ),
                        ),
                    ],
                ),
                LSDivider(),
                LSContainerRow(
                    children: <Widget>[
                        Expanded(
                            child: LSButton(
                                text: 'Download',
                                onTap: () => _downloadAction(),
                                reducedMargin: true,
                            ),
                        ),
                        if(!_arguments.data.approved) Expanded(
                            child: LSButton(
                                text: 'Rejected',
                                backgroundColor: LSColors.red,
                                onTap: () => _warningAction(),
                                reducedMargin: true,
                            ),
                        ),
                    ],
                ),
            ],
            padBottom: true,
        );

    Future<void> _warningAction() async => _showWarnings();

    Future<void> _downloadAction() async {
        if(_arguments.data.approved) {
            await _startDownload()
            .then((_) => LSSnackBar(context: context, title: 'Downloading...', message: _arguments.data.title, type: SNACKBAR_TYPE.success))
            .catchError((_) => LSSnackBar(context: context, title: 'Failed to Start Downloading', message: Constants.CHECK_LOGS_MESSAGE, type: SNACKBAR_TYPE.failure));
        } else {
            List<dynamic> values = await LSDialogSonarr.showDownloadWarningPrompt(context);
            if(values[0]) await _startDownload()
            .then((_) => LSSnackBar(context: context, title: 'Downloading...', message: _arguments.data.title, type: SNACKBAR_TYPE.success))
            .catchError((_) => LSSnackBar(context: context, title: 'Failed to Start Downloading', message: Constants.CHECK_LOGS_MESSAGE, type: SNACKBAR_TYPE.failure));
        }
    }

    Future<void> _showWarnings() async {
        String reject = '';
        for(var i=0; i<_arguments.data.rejections.length; i++) {
            reject += '${i+1}. ${_arguments.data.rejections[i]}\n';
        }
        await LSDialogSystem.textPreview(context, 'Rejection Reasons', reject.substring(0, reject.length-1));
    }

    Future<bool> _startDownload() async {
        SonarrAPI _api = SonarrAPI.from(Database.currentProfileObject);
        return await _api.downloadRelease(_arguments.data.guid, _arguments.data.indexerId);
    }
}
