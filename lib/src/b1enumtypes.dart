///A base class sor B1 enumerations
abstract class BoEnums {
  final String value;
  const BoEnums(this.value) : assert(value != null);
  @override bool operator == (v) => this.value == v.toString();
  @override String toString() => value;
}

class BoYesNoEnum extends BoEnums {
  static const tNO = BoYesNoEnum("tNO");
  static const tYES = BoYesNoEnum("tYES");
  const BoYesNoEnum(String value) : super(value);
}
