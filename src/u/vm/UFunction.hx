package u.vm;

import u.parser.AST;
import u.parser.Expr;

class UFunction {

	private var values:Map<String, Float>;
	
	private var functionmap:Map<String, UFunction>;
	var name:String;
	var params:Array<Param>;
	var statements:Array<Statement>;

	public function new(name, params, statements) {
		this.name = name;
		this.params = params;
		this.statements = statements;
		this.values = new Map<String, Float>();
		this.functionmap = new Map<String, UFunction>();
	}

	public function eval(params:Array<Dynamic>):Dynamic {
		return this.eval_program(params);
	}

	public function eval_program(input_params:Array<Dynamic>) {
		var i=0;
		for(p in this.params) {
			switch(p) {
				case Param.PParam(type, name):
					this.values.set(name, input_params[i]);
			}
			i++;
		}
		for(s in this.statements) {
			if(s != null) {
				var r = eval_statement(s);
				if(r != null) {
					return r;
				}
			}
		}
		return null;
	}

	public function eval_statement(statement:Statement):Dynamic {
		return switch(statement) {
			case Statement.SExpr( expr ):
				eval_expr(expr);
				null;
			case Statement.SReturn( expr ):
				eval_expr(expr);
			case Statement.SWords( words ):
				null;
			case Statement.SRestriction( left , expr ):
				this.values.set(left[0], eval_expr(expr));
				null;
			case Statement.SDefClass( left , attrs ):
				null;
			case Statement.SDefFunction(name, params, statements):
				this.functionmap.set(name, new UFunction(name, params, statements));
				null;
			default:
				null;
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
				if(this.functionmap.get(name) != null) {
					var input_params = new Array<Dynamic>();
					for(p in params) {
						input_params.push(eval_expr(p));
					}
					return this.functionmap.get(name).eval(input_params);
				}else
					return 0;
			default:
				0.0;
		}
	}}