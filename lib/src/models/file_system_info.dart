class FileSystemInfo {

  FileSystemInfo(String entry,): _raw = entry {
    final items = entry.split(RegExp(r"\s"),);
    fsSpec = items[0];
    mountPoint = items[1];
    type = items[2];
    mountOptions = items[3].split(",",);
    dumpId = int.parse(items[4],);
    checkPriority = int.parse(items[5],);
  }

  late final String _raw;
  late final String fsSpec;
  late final String mountPoint;
  late final String type;
  late final List<String> mountOptions;
  late final int dumpId;
  late final int checkPriority;

  String get fsFile => mountPoint;
  String get fsVFsType => type;
  List<String> get fsMntOps => mountOptions;
  int get fsFreq => dumpId;

  late final bool doNotDump = dumpId == 0;
  late final bool doNotCheck = checkPriority == 0;

  @override
  String toString() => _raw;
}