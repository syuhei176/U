package u.vm;

import u.parser.AST;
import u.parser.Expr;
import u.vm.UObjectReference;

class UObject {
	private var address:String;
	private var uclass:UClass;
	private var values:Map<String, UObject>;

	public function new(address:String, uclass) {
		this.uclass = uclass;
	}

	public function call(name, params:Array<UObjectReference>):UObjectReference {
		return this.uclass.call(name, UObjectReference.UObject(this), params);
	}

}