// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class BeautySettingPage extends StatefulWidget {
  final int beautyLevel;

  BeautySettingPage({Key? key, required this.beautyLevel});

  @override
  _BeautySettingPageState createState() {
    return _BeautySettingPageState();
  }
}

class _BeautySettingPageState extends BaseState<BeautySettingPage> {
  NERtcVideoRenderer? renderer;
  late int beautyLevel;
  NEPreviewRoomRtcController? previewRoomRtcController;

  @override
  void initState() {
    super.initState();
    beautyLevel = widget.beautyLevel;
    _checkPermission().then((granted) {
      if (granted) {
        NERoomKit.instance.roomService
            .previewRoom(NEPreviewRoomParams(), NEPreviewRoomOptions())
            .then((value) {
          previewRoomRtcController = value.nonNullData.previewController;
          _initRenderer();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
                title: Text(
                  _Strings.beauty,
                  style: TextStyle(
                      color: _UIColors.color_222222,
                      fontSize: 19,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w500),
                ),
                centerTitle: true,
                backgroundColor: Colors.white,
                elevation: 0.0,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                leading: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  key: ValueKey('back'),
                  child: Container(
                      width: 150,
                      height: 40,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 20, bottom: 10),
                      child: Text(
                        _Strings.save,
                        style: TextStyle(
                            color: Color(0xff2575FF),
                            fontSize: 14,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w500),
                      )),
                  onTap: () {
                    _requestPop();
                  },
                )),
            body: buildBeautyPreViewWidget(context)),
        onWillPop: () async {
          _requestPop();
          return false;
        });
  }

  Widget buildBeautyPreViewWidget(BuildContext context) {
    return Stack(children: <Widget>[
      buildCallingVideoViewWidget(context),
      Positioned(
        bottom: 0,
        right: 0,
        left: 0,
        child: SliderWidget(
            onChange: (value) {
              _setBeautyParams(value);
            },
            level: beautyLevel.toInt(),
            isShowClose: false),
      )
    ]);
  }

  Widget buildCallingVideoViewWidget(BuildContext context) {
    return renderer != null ? NERtcVideoView(renderer!) : Container();
  }

  Future<bool> _checkPermission() async {
    var granted = (await Permission.camera.status) == PermissionStatus.granted;
    if (!granted) {
      granted = await PermissionHelper.requestPermissionSingle(
          context, Permission.camera, '', _Strings.cameraPermission);
      if (!granted) UINavUtils.pop(context, rootNavigator: true);
    }
    return granted;
  }

  void _requestPop() {
    SettingsRepository.setBeautyFaceValue(beautyLevel);
    UINavUtils.pop(context, rootNavigator: true);
  }

  Future<void> _initRenderer() async {
    renderer = await VideoRendererFactory.createVideoRenderer('');
    await renderer!.attachToLocalVideo();
    if (Platform.isAndroid) {
      renderer!.setMirror(true);
    }
    await previewRoomRtcController?.startPreview();
    await previewRoomRtcController?.startBeauty();
    await previewRoomRtcController?.enableBeauty(true);
    _setBeautyParams(beautyLevel);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    EventBus().emit(NEMeetingUIEvents.flutterPageDisposed);
    SettingsRepository.setBeautyFaceValue(beautyLevel);
    previewRoomRtcController?.stopBeauty();
    previewRoomRtcController?.stopPreview();
    renderer?.detach();
    super.dispose();
  }

  void _setBeautyParams(int v) {
    beautyLevel = v;
    var level = beautyLevel.toDouble() / 10;
    previewRoomRtcController?.setBeautyEffect(
        NERoomBeautyEffectType.kWhiten, level);
    previewRoomRtcController?.setBeautyEffect(
        NERoomBeautyEffectType.kSmooth, level);
    previewRoomRtcController?.setBeautyEffect(
        NERoomBeautyEffectType.kFaceRuddy, level);
    previewRoomRtcController?.setBeautyEffect(
        NERoomBeautyEffectType.kFaceSharpen, level);
  }
}
