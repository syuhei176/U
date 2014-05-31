package u.vm;

import u.parser.AST;
import u.parser.Expr;

class Vm {

	private var values:Map<String, Float>;
	public var classmap:Map<String, UClass>;
	private var main:UFunction;

	public function new() {
		this.values = new Map<String, Float>();
		this.classmap = new Map<String, UClass>();
	}

	public function read_statements(statements:Array<Statement>) {
		for(s in statements) {
			this.eval_statement(s);
		}
		//this.main = new UFunction( "main" , new Array<u.parser.Param>(), statements);
		//var result = this.main.eval(null);
		//trace( result );
	}

	public function eval_program() {
		var mainClass = this.classmap.get("Main");
		var result = mainClass.call_static("main", null);
		trace( result );
	}

	public function eval_statement(statement:Statement) {
		switch(statement) {
			case Statement.SDefClass( name , elems ):
				this.classmap.set(name, new UClass(this, name, elems));
			default:
		}
	}
}