// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

extension NEMeetingUIRtcController on NERoomRtcController {
  Future<VoidResult> unmuteMyAudioWithCheckPermission(
      BuildContext context, String title,
      {bool needAwaitResult = true}) {
    return PermissionHelper.enableLocalAudioAndCheckPermission(
            context, true, title)
        .then((enable) {
      if (enable) {
        final result = unmuteMyAudio();
        return needAwaitResult
            ? result
            : Future.value(const VoidResult.success());
      }
      return const NEResult<void>(code: -1, msg: _Strings.noPermission);
    });
  }

  Future<VoidResult> unmuteMyVideoWithCheckPermission(
      BuildContext context, String title,
      {bool needAwaitResult = true}) {
    return PermissionHelper.enableLocalVideoAndCheckPermission(
            context, true, title)
        .then((enable) {
      if (enable) {
        final result = unmuteMyVideo();
        return needAwaitResult
            ? result
            : Future.value(const VoidResult.success());
      }
      return const NEResult<void>(code: -1, msg: _Strings.noPermission);
    });
  }
}
