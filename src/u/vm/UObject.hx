package u.vm;

import u.parser.AST;
import u.parser.AST.Expr;
import u.vm.UObjectReference;

class UObject {
	private var address:String;
	private var uclass:UClass;
	private var values:Map<String, UObjectReference>;

	public function new(address:String, uclass) {
		this.uclass = uclass;
		this.values = new Map<String, UObjectReference>();
	}

	public function call(name, params:Array<UObjectReference>):UObjectReference {
		return this.uclass.call(name, UObjectReference.UObject(this), params);
	}

	public function set(key, obj:UObjectReference) {
		this.values.set(key, obj);
	}

	public function get(key):UObjectReference {
		return this.values.get(key);
	}

}