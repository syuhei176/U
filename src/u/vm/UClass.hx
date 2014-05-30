package u.vm;

import u.parser.AST;
import u.parser.Expr;

class UClass {
	private var name:String;
	private var attrs:Map<String, Attr>;
	private var methods:Map<String, UFunction>;

	public function new(name:String, elems:Array<ClassElement>) {
		this.attrs = new Map<String, Attr>();
		this.methods = new Map<String, UFunction>();
		for(e in elems) {
			switch (e) {
				case ClassElement.Attr( type , name ):
					this.attrs.set(name, {type:type, name:name});
				case ClassElement.Method( name , params , statements ):
					this.methods.set(name, new UFunction(name, params, statements));
			}
		}
	}

	public function call_constructor(params) {
		return new UObject("address");
	}

	public function call(name, self, params) {
		this.methods.get(name).eval(params);
	}

}
