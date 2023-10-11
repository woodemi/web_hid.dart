part of '../web_hid.dart';

class Hid extends Delegate<EventTarget> {
  Hid._(EventTarget delegate) : super(delegate);
  late EventListener _connectListener;
  late EventListener _disconnectListener;

  Future<List<HidDevice>> requestDevice([RequestOptions? options]) {
    var promise =
    callMethod('requestDevice', [options ?? RequestOptions(filters: [])]);
    return promiseToFuture(promise).then((value) {
      return (value as List).map((e) => HidDevice._(e)).toList();
    });
  }

  Future<List<HidDevice>> getDevices() {
    var promise = callMethod('getDevices');
    return promiseToFuture(promise).then((value) {
      return (value as List).map((e) => HidDevice._(e)).toList();
    });
  }

  void subscribeConnect(Function(HIDConnectionEvent) listener) {
    _connectListener = allowInterop((event){
      listener(HIDConnectionEvent._(event));
    });
    setProperty('onconnect', _connectListener);
  }

  void unsubscribeConnect(Function() listener) {
    setProperty('onconnect', null);
    listener();
  }

  void subscribeDisconnect(Function(HIDConnectionEvent) listener) {
    _disconnectListener = allowInterop((event){
      listener(HIDConnectionEvent._(event));
    });
    setProperty('ondisconnect', _disconnectListener);
  }

  void unsubscribeDisconnect(Function() listener) {
    setProperty('ondisconnect', null);
    listener();
  }
}

@JS()
@anonymous
class RequestOptions {
  external factory RequestOptions({
    required List<dynamic> filters,
  });
}

@JS()
@anonymous
class RequestOptionsFilter {
  external factory RequestOptionsFilter({
    int vendorId,
    int productId,
    int usage,
    int usagePage,
  });
}

class HidDevice extends Delegate<EventTarget> {
  HidDevice._(EventTarget delegate) : super(delegate);
  late EventListener _eventListener;

  Future<void> open() {
    var promise = callMethod('open');
    return promiseToFuture(promise);
  }

  Future<void> close() {
    var promise = callMethod('close');
    return promiseToFuture(promise);
  }

  Future<void> forget() {
    var promise = callMethod('forget');
    return promiseToFuture(promise);
  }

  bool get opened => getProperty('opened');
  int get vendorId => getProperty('vendorId');
  int get productId  => getProperty('productId');
  String get productName => getProperty('productName');
  List<HIDCollectionInfo> get collections => (getProperty('collections') as List).map((e) => HIDCollectionInfo._(e)).toList();

  Future<void> sendReport(int requestId, TypedData data) {
    var promise = callMethod('sendReport', [requestId, data]);
    return promiseToFuture(promise);
  }

  void subscribeInputReport(Function(HIDInputReportEvent) listener) {
    _eventListener = allowInterop((Event event) {
      listener(HIDInputReportEvent._(event));
    });
    setProperty('oninputreport', _eventListener);
  }

  void unsubscribeInputReport(Function() listener) {
    setProperty('oninputreport', null);
    listener();
  }

  Future<void> sendFeatureReport(int requestId, TypedData data) {
    var promise = callMethod('sendFeatureReport', [requestId, data]);
    return promiseToFuture(promise);
  }

  Future<Uint8List> receiveFeatureReport(int requestId){
    var promise = callMethod('receiveFeatureReport', [requestId]);
    return promiseToFuture(promise).then((value) =>
        (value as ByteData).buffer.asUint8List()
    );
  }

  @override
  String toString(){
    var str = '';
    var list = collections;
    if(list.isEmpty){
      str ='collections: None';
    }
    else{
      for(int i = 0; i < list.length; i++){
        str += 'collections[$i]:\n';
        str += list[i].toString();
      }
    }

    return """HidDeviceInfo
opened:      $opened
vendorId:    0x${_toHexString(vendorId, len:4)}
productId:   0x${_toHexString(productId, len:4)}
productName: $productName
$str""";
  }
}

class HIDInputReportEvent extends Delegate<Event> {
  HIDInputReportEvent._(Event delegate) : super(delegate);

  ByteData get data => getProperty('data');
  int get reportId => getProperty('reportId');
  HidDevice get device => HidDevice._(getProperty('device'));

  Uint8List rawData(){
    List<int> dataList = [reportId];
    dataList.addAll(data.buffer.asUint8List());
    return Uint8List.fromList(dataList);
  }

  @override
  String toString() {
    return """${device.toString()}
reportId: 0x${_toHexString(reportId)}
data: 
${data.buffer.asUint8List().asMap().map((i,e){
  var hex = _toHexString(e);
  hex += ((i + 1) % 16 == 0) ? '\n' : ' ';
  return MapEntry(i, hex);
}).values.join()}
""";
  }
}

class HIDConnectionEvent extends Delegate<Event> {
  HIDConnectionEvent._(Event delegate) : super(delegate);

  HidDevice get device => HidDevice._(getProperty('device'));
}

class HIDCollectionInfo extends Delegate<Object>{
  HIDCollectionInfo._(Object delegate) : super(delegate);

  int get usagePage => getProperty('usagePage');
  int get usage => getProperty('usage');
  int get type => getProperty('type');
  List<HIDCollectionInfo> get children => (getProperty('children') as List).map((e) => HIDCollectionInfo._(e)).toList();
  List<HIDReportInfo> get inputReports => (getProperty('inputReports') as List).map((e) => HIDReportInfo._(e)).toList();
  List<HIDReportInfo> get outputReports => (getProperty('outputReports') as List).map((e) => HIDReportInfo._(e)).toList();
  List<HIDReportInfo> get featureReports => (getProperty('featureReports') as List).map((e) => HIDReportInfo._(e)).toList();
  @override
  String toString(){
    String str = '';
    var input = inputReports;
    var output = outputReports;
    var feature = featureReports;
    for(var e in input){
      str += '  Input ${e.toString()}';
    }
    for(var e in output){
      str += '  Output ${e.toString()}';
    }
    for(var e in feature){
      str += '  Feature ${e.toString()}';
    }

    return """  usagePage: 0x${_toHexString(usagePage)}
  usage:     0x${_toHexString(usage)}
  type:      0x${_toHexString(type, len:1)}
$str""";
  }
}

class HIDReportInfo extends Delegate<Object> {
  HIDReportInfo._(Object delegate) : super(delegate);

  int get reportId => getProperty('reportId');
  List<HIDReportItem> get items => (getProperty('items') as List).map((e) => HIDReportItem._(e)).toList();
  
  @override
  String toString(){
    String str = '';
    var list = items;
    for(var e in list){
      str += e.toString();
    }
    return """report Id: 0x${_toHexString(reportId)}
$str""";
  }
}

class HIDReportItem extends Delegate<Object> {
  HIDReportItem._(Object delegate) : super(delegate);

  bool get isAbsolute => getProperty('isAbsolute');
  bool get isArray => getProperty('isArray');
  bool get isBufferedBytes => getProperty('isBufferedBytes');
  bool get isConstant => getProperty('isConstant');
  bool get isLinear => getProperty('isLinear');
  bool get isRange => getProperty('isRange');
  bool get isVolatile => getProperty('isVolatile');
  bool get hasNull => getProperty('hasNull');
  bool get hasPreferredState => getProperty('hasPreferredState');
  bool get wrap => getProperty('wrap');
  int get usageMinimum => getProperty('usageMinimum');
  int get usageMaximum => getProperty('usageMaximum');
  int get reportSize => getProperty('reportSize');
  int get reportCount => getProperty('reportCount');
  int get unitExponent => getProperty('unitExponent');
  int get unitFactorLengthExponent => getProperty('unitFactorLengthExponent');
  int get unitFactorMassExponent => getProperty('unitFactorMassExponent');
  int get unitFactorTimeExponent => getProperty('unitFactorTimeExponent');
  int get unitFactorTemperatureExponent => getProperty('unitFactorTemperatureExponent');
  int get unitFactorCurrentExponent => getProperty('unitFactorCurrentExponent');
  int get unitFactorLuminousIntensityExponent => getProperty('unitFactorLuminousIntensityExponent');
  int get logicalMinimum => getProperty('logicalMinimum');
  int get logicalMaximum => getProperty('logicalMaximum');
  int get physicalMinimum => getProperty('physicalMinimum');
  int get physicalMaximum => getProperty('physicalMaximum');
  String get unitSystem => getProperty('unitSystem');
  List<int> get usages => List<int>.from((getProperty('usages') ?? []) as List);

  String reportSizeAndCountAsString() {
    var bitWidth = reportCount * reportSize;
    if (bitWidth == 1) {
      return '1 bit';
    }
    if (reportCount == 1) {
      return '$reportSize bits';
    }

    return '$reportCount value${reportCount > 0?'s':''} * $reportSize bit${reportSize > 0?'s':''}';
  }

  String bitFieldAsString(){
    List<String> bits = [];
    bits.add(isConstant ? 'Cnst' : 'Data');
    bits.add(isArray ? 'Ary' : 'Var');
    bits.add(isAbsolute ? 'Abs' : 'Rel');
    if (wrap) bits.add('Wrap');
    if (!isLinear) bits.add('NLin');
    if (!hasPreferredState) bits.add('NPrf');
    if (hasNull) bits.add('Null');
    if (isVolatile) bits.add('Vol');
    if (isBufferedBytes) bits.add('Buf');
    return bits.join(',');
  }

  String usageAsString(int usage){
    var usagePage = usage >>> 16;
    var usageId = usage & 0xffff;
    var usageString = '${_toHexString(usagePage, len:4)}:${_toHexString(usageId, len:4)}';

    String usagePageName;

    if (usagePage >= 0xFF00) {
      usagePageName = 'Vendor-defined page 0x${_toHexString(usagePage, len:4)}';
    }
    else {
      usagePageName = 'Unknown usage page 0x${_toHexString(usagePage, len:4)}';
    }

    // Consider any usage ID from the Button, Ordinal, Unicode, and Monitor Enumerated Values pages as valid usages.
    if (usagePage == 0x0009) {
      return '$usageString ($usagePageName Button $usageId)';
    }
    if (usagePage == 0x000A) {
      return '$usageString ($usagePageName Instance $usageId)';
    }
    if (usagePage == 0x0010) {
      return '$usageString ($usagePageName U+${_toHexString(usageId, len:4)})';
    }
    if (usagePage == 0x0081) {
      return '$usageString ($usagePageName ENUM_$usageId)';
    }

    return '$usageString ($usagePageName usage 0x${_toHexString(usageId, len:4)})';

  }

  String usagesAsString() {
    if (isRange) {
      if (usageMinimum == usageMaximum) {
        return 'Usage: ${usageAsString(usageMinimum)}';
      }
      else {
        return 'Usages: ${usageAsString(usageMinimum)} to ${usageAsString(usageMaximum)}';
      }
    }

    List<String>  usageStrings = [];
    for (var usage in usages) {
      usageStrings.add(usageAsString(usage));
    }
    if (usageStrings.length == 1) {
      return 'Usage: ${usageStrings[0]}';
    }
    else {
      return 'Usages:\n      ${usageStrings.join('\n      ')}';
    }
  }

  void _addUnitFactor(
      List<String>numerator,
      List<String>denominator,
      String unitFactorName,
      int unitFactorExponent){
      if (unitFactorExponent == 0) {
        return;
      }

    var absoluteExponent = unitFactorExponent.abs();
    var exponent = (absoluteExponent == 1) ? '' : '^$absoluteExponent';
    if (unitFactorExponent > 0) {
      numerator.add(unitFactorName + exponent);
    } else {
      denominator.add(unitFactorName + exponent);
    }
  }

  String unitsAsString() {
    String lengthName;
    String massName;
    String timeName;
    String temperatureName;
    String currentName;
    String luminousIntensityName;
    switch(unitSystem){
      case 'si-linear':
        lengthName = 'cm';  // Centimeter
        massName = 'g';  // Gram
        timeName = 's';  // Seconds
        temperatureName = 'K';  // Kelvin
        currentName = 'A';  // Ampere
        luminousIntensityName = 'cd';  // Candela
        break;
      case 'si-rotation':
        lengthName = 'rad';  // Radians
        massName = 'g';  // Gram
        timeName = 's';  // Seconds
        temperatureName = 'K';  // Kelvin
        currentName = 'A';  // Ampere
        luminousIntensityName = 'cd';  // Candela
        break;
      case 'eng lish-linear':
        lengthName = 'in';  // Inch
        massName = 'slug';  // Slug
        timeName = 's';  // Seconds
        temperatureName = '°F';  // Fahrenheit
        currentName = 'A';  // Ampere
        luminousIntensityName = 'cd';  // Candela
        break;
      case 'english-rotation':
        lengthName = 'deg';  // Degrees
        massName = 'slug';  // Slug
        timeName = 's';  // Seconds
        temperatureName = '°F';  // Fahrenheit
        currentName = 'A';  // Ampere
        luminousIntensityName = 'cd';  // Candela
        break;
      default:
        lengthName = 'length';
        massName = 'mass';
        timeName = 'time';
        temperatureName = 'temperature';
        currentName = 'current';
        luminousIntensityName = 'luminous-intensity';
        break;
    }

    List<String> numeratorFactors = [];
    List<String> denominatorFactors = [];
    _addUnitFactor(numeratorFactors, denominatorFactors, lengthName, unitFactorLengthExponent);
    _addUnitFactor(numeratorFactors, denominatorFactors, massName, unitFactorMassExponent);
    _addUnitFactor(numeratorFactors, denominatorFactors, timeName, unitFactorTimeExponent);
    _addUnitFactor(numeratorFactors, denominatorFactors, temperatureName, unitFactorTemperatureExponent);
    _addUnitFactor(numeratorFactors, denominatorFactors, currentName, unitFactorCurrentExponent);
    _addUnitFactor(numeratorFactors, denominatorFactors, luminousIntensityName, unitFactorLuminousIntensityExponent);

    var exponent = (unitExponent == 0) ? '' : '10^$unitExponent*';
    var numerator = (numeratorFactors.isNotEmpty) ? numeratorFactors.join('*') : '1';
    if (denominatorFactors.isEmpty) {
      return 'Units: $exponent$numerator';
    }

    var denominator = denominatorFactors.join('*');
    return 'Units: $exponent$numerator/$denominator';
  }

  @override
  String toString(){
    String str = '    ${reportSizeAndCountAsString()}\n';
    str += '      ${bitFieldAsString()}\n';
    if(isRange || usages.isNotEmpty){
      str += '      ${usagesAsString()}\n';
    }
    str += '      Logical bounds: $logicalMinimum to $logicalMaximum\n';
    if(physicalMinimum != 0 || physicalMaximum != physicalMinimum){
      str += '      Physical bounds: $physicalMinimum to $physicalMaximum\n';
    }
    if(unitFactorLengthExponent != 0 ||
        unitFactorMassExponent != 0 ||
        unitFactorTimeExponent != 0 ||
        unitFactorTemperatureExponent != 0 ||
        unitFactorCurrentExponent != 0 ||
        unitFactorLuminousIntensityExponent != 0 ||
        unitExponent != 0 ||
        unitSystem != 'none'){
      str += '      ${unitsAsString()}\n';
    }
    return str;
  }
}

String _toHexString(int value, {int len = 2}){
  return value.toRadixString(16).toUpperCase().padLeft(len,'0');
}