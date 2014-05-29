package u.vm;

import u.parser.AST;
import u.parser.Expr;

class Vm {

	private var values:Map<String, Float>;
	private var functionmap:Map<String, UFunction>;
	private var main:UFunction;

	public function new() {
		this.values = new Map<String, Float>();
		this.functionmap = new Map<String, UFunction>();
	}

	public function eval_program(statements:Array<Statement>) {
		this.main = new UFunction( new Array<String>() , new Array<u.parser.Param>(), statements);
		this.main.eval(null);
	}

	public function eval_statement(statement:Statement):Dynamic {
		return switch(statement) {
			case Statement.SWords( words ):
				0.0;
			case Statement.SDefClass( left , attrs ):
				"Class";
			case Statement.SDefFunction(left, params, statements):
				functionmap.set(left[1], new UFunction(left, params, statements));
				"Function";
			default:
				0.0;
		}
	}
}