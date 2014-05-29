package u.vm;

import u.parser.AST;
import u.parser.Expr;

class UFunction {

	private var values:Map<String, Float>;
	
	private var functionmap:Map<String, UFunction>;
	var left:Array<String>;
	var params:Array<Param>;
	var statements:Array<Statement>;

	public function new(left, params, statements) {
		this.left = left;
		this.params = params;
		this.statements = statements;
	}

	public function eval(params) {
		this.eval_program(this.statements, params);
	}

	public function eval_program(statements:Array<Statement>, params) {
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
				this.functionmap.set(left[1], new UFunction(left, params, statements));
				"Function";
			default:
				0.0;
		}
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
			case Expr.ECall( name , params ):
				this.functionmap.get(name).eval(params);
			default:
				0.0;
		}
	}}