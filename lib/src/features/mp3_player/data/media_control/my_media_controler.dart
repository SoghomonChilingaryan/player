import 'package:audio_service/audio_service.dart';

class MyMediaControl {
  static const rewind10 = MediaControl(
    androidIcon: 'drawable/rewind_10_35',
    label: 'rewind_10',
    action: MediaAction.rewind,
  );
  static const push10 = MediaControl(
    androidIcon: 'drawable/push_10_35',
    label: 'push_10',
    action: MediaAction.stop,
  );
  static const rewind30 = MediaControl(
    androidIcon: 'drawable/rewind_30_35',
    label: 'rewind_30',
    action: MediaAction.skipToPrevious,
  );
  static const push30 = MediaControl(
    androidIcon: 'drawable/push_30_35',
    label: 'push_30',
    action: MediaAction.skipToNext,
  );

  // static const seekBackward = MediaControl(
  //   androidIcon: 'drawable/audio_service_fast_rewind',
  //   label: 'seekBackward',
  //   action: MediaAction.seekBackward,
  // );
  // static const seekForward = MediaControl(
  //   androidIcon: 'drawable/audio_service_stop',
  //   label: 'seekForward',
  //   action: MediaAction.seekForward,
  // );
}