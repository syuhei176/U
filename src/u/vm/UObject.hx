package u.vm;

import u.parser.AST;
import u.parser.Expr;

class UObject {
	private var address:String;
	private var uclass:UClass;
	private var values:Map<String, UObject>;

	public function new(address:String) {

	}

	public function call(name, params) {
		this.uclass.call(name, values, params);
	}

}