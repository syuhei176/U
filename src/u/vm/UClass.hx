package u.vm;

import u.parser.AST;
import u.parser.Expr;
import u.vm.UObjectReference;

class UClass {
	private var name:String;
	private var attrs:Map<String, Attr>;
	private var methods:Map<String, UFunction>;
	private var vm:Vm;

	public function new(vm:Vm, name:String, elems:Array<ClassElement>) {
		this.vm = vm;
		this.attrs = new Map<String, Attr>();
		this.methods = new Map<String, UFunction>();
		for(e in elems) {
			switch (e) {
				case ClassElement.Attr( type , name ):
					this.attrs.set(name, {type:type, name:name});
				case ClassElement.Method( name , params , statements ):
					this.methods.set(name, new UFunction(this.vm, name, params, statements));
			}
		}
	}

	public function call_constructor(params) {
		return new UObject("address", this);
	}

	public function call(name, self, params:Array<UObjectReference>):UObjectReference {
		this.methods.get(name).set_self(self);
		return this.methods.get(name).eval(params);
	}

	public function call_static(name, params) {
		return this.methods.get(name).clone().eval(params);
	}
}
