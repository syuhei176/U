package u.vm;

enum UObjectReference {
	UClass(klass:UClass);
	UObject(object:UObject);
	UString(str:String);
	UNumber(i:Float);
	UBool(b:Bool);
	UNull;
	UError;
}

class UObjectReferenceOperation {
	static public function plus(objref1, objref2) {
		return switch(objref1) {
			case UObjectReference.UObject(object):
				return switch(objref2) {
					default:
						UObjectReference.UError;
				}
			case UObjectReference.UString(str1):
				return switch(objref2) {
					case UObjectReference.UString(str2):
						UObjectReference.UString(str1 + str2);
					case UObjectReference.UNumber(i2):
						UObjectReference.UString(str1 + i2);
					default:
						UObjectReference.UError;
				}
			case UObjectReference.UNumber(i1):
				return switch(objref2) {
					case UObjectReference.UString(str2):
						UObjectReference.UString(i1 + str2);
					case UObjectReference.UNumber(i2):
						UObjectReference.UNumber(i1 + i2);
					default:
						UObjectReference.UError;
				}
			case UObjectReference.UBool(b):
				UObjectReference.UError;
			default:
				UObjectReference.UError;
		}
	}
	static public function minus(objref1, objref2) {
		return switch(objref1) {
			case UObjectReference.UNumber(i1):
				return switch(objref2) {
					case UObjectReference.UNumber(i2):
						UObjectReference.UNumber(i1 - i2);
					default:
						UObjectReference.UError;
				}
			default:
				UObjectReference.UError;
		}
	}
	static public function times(objref1, objref2) {
		return switch(objref1) {
			case UObjectReference.UNumber(i1):
				return switch(objref2) {
					case UObjectReference.UNumber(i2):
						UObjectReference.UNumber(i1 * i2);
					default:
						UObjectReference.UError;
				}
			default:
				UObjectReference.UError;
		}
	}
	static public function div(objref1, objref2) {
		return switch(objref1) {
			case UObjectReference.UNumber(i1):
				return switch(objref2) {
					case UObjectReference.UNumber(i2):
						UObjectReference.UNumber(i1 / i2);
					default:
						UObjectReference.UError;
				}
			default:
				UObjectReference.UError;
		}
	}
	static public function eq(objref1, objref2) {
		return switch(objref1) {
			case UObjectReference.UNumber(i1):
				return switch(objref2) {
					case UObjectReference.UNumber(i2):
						UObjectReference.UBool(i1 == i2);
					default:
						UObjectReference.UError;
				}
			default:
				UObjectReference.UError;
		}
	}
	static public function le(objref1, objref2) {
		trace(objref1, objref2);
		return switch(objref1) {
			case UObjectReference.UNumber(i1):
				return switch(objref2) {
					case UObjectReference.UNumber(i2):
						UObjectReference.UBool(i1 <= i2);
					default:
						UObjectReference.UError;
				}
			default:
				UObjectReference.UError;
		}
	}
}