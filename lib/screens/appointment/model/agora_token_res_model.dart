class AgoraTokenRes {
  bool status;
  String token;
  String channelName;
  int uid;
  String message;

  AgoraTokenRes({
    this.status = false,
    this.token = "",
    this.channelName = "",
    this.uid = 0,
    this.message = "",
  });

  factory AgoraTokenRes.fromJson(Map<String, dynamic> json) {
    return AgoraTokenRes(
      status: json['status'] is bool ? json['status'] : false,
      token: json['data'] is Map
          ? (json['data']['token'] is String ? json['data']['token'] : "")
          : (json['token'] is String ? json['token'] : ""),
      channelName: json['data'] is Map
          ? (json['data']['channel_name'] is String ? json['data']['channel_name'] : "")
          : (json['channel_name'] is String ? json['channel_name'] : ""),
      uid: json['data'] is Map
          ? (json['data']['uid'] is int ? json['data']['uid'] : 0)
          : (json['uid'] is int ? json['uid'] : 0),
      message: json['message'] is String ? json['message'] : "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'token': token,
      'channel_name': channelName,
      'uid': uid,
      'message': message,
    };
  }
}
