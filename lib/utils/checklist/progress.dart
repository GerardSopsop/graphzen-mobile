class Progress {
  Map<String, dynamic> taskId;

  Progress(
      {this.taskId = const {
        'value': 0,
        'alias': '',
        'signer': '',
        'sign': '',
        'date': 0,
        'signed_version': ''
      }});
}
