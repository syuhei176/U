package u.vm;

import u.parser.AST;
import u.parser.Expr;

class UFunction {

}

class Vm {

	private var values:Map<String, Float>;
	private var functionmap:Map<String:UFunction>;

	public function new() {
		this.values = new Map<String, Float>();
	}

	public function eval_program(statements:Array<Statement>) {
		for(s in statements) {
			trace(eval_statement(s));
		}
	}

	public function eval_statement(statement:Statement):Dynamic {
		return switch(statement) {
			case Statement.SExpr( expr ):
				eval_expr(expr);
			case Statement.SWords( words ):
				0.0;
			case Statement.SRestriction( left , expr ):
				this.values.set(left[0], eval_expr(expr));
				0.0;
			case Statement.SDefClass( left , attrs ):
				"Class";
			case Statement.SDefFunction(left, params, statements):
				"Function";
			default:
				0.0;
		}
	}

	public function eval_function() {

	}

	public function eval_expr(expr:Expr):Dynamic {
		return switch(expr) {
			case Expr.Plus( left, right ):
				eval_expr(left) + eval_expr(right);
			case Expr.Minus( left, right ):
				eval_expr(left) - eval_expr(right);
			case Expr.Times( left, right ):
				eval_expr(left) * eval_expr(right);
			case Expr.Div( left, right ):
				eval_expr(left) / eval_expr(right);
			case Expr.EBucket( expr ):
				eval_expr(expr);
			case Expr.EString( str ):
				this.values.get(str);
			case Expr.ENumber( str ):
				Std.parseFloat(str);
			case Expr.ECall( name , params )
				eval_function(name, params);
			default:
				0.0;
		}
	}
}