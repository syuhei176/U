package u.vm;

import u.parser.AST;
import u.parser.Expr;
import u.vm.UObjectReference;

class UFunction {

	private var values:Map<String, UObjectReference>;
	
	private var functionmap:Map<String, UFunction>;
	private var classmap:Map<String, UClass>;
	var name:String;
	var params:Array<Param>;
	var statements:Array<Statement>;
	private var vm:Vm;

	public function new(vm, name, params, statements) {
		this.vm = vm;
		this.name = name;
		this.params = params;
		this.statements = statements;
		this.values = new Map<String, UObjectReference>();
		this.functionmap = new Map<String, UFunction>();
		this.classmap = new Map<String, UClass>();
	}

	public function eval(params:Array<UObjectReference>):UObjectReference {
		return this.eval_program(params);
	}

	public function set_self(self:UObjectReference) {
		this.values.set("this", self);
	}

	public function eval_program(input_params:Array<UObjectReference>) {
		var i=0;
		for(p in this.params) {
			switch(p) {
				case { type : _type , name : _name }:
					this.values.set(_name, input_params[i]);
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

	public function eval_statement(statement:Statement):UObjectReference {
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
			case Statement.SDefClass( name , elems ):
				this.classmap.set(name, new UClass(this.vm, name, elems));
				null;
			case Statement.SDefFunction(name, params, statements):
				this.functionmap.set(name, new UFunction(this.vm, name, params, statements));
				null;
			default:
				null;
		}
	}

	public function eval_expr(expr:Expr):UObjectReference {
		return switch(expr) {
			case Expr.Plus( left, right ):
				UObjectReferenceOperation.plus(eval_expr(left), eval_expr(right));
			case Expr.Minus( left, right ):
				UObjectReferenceOperation.minus(eval_expr(left), eval_expr(right));
			case Expr.Times( left, right ):
				UObjectReferenceOperation.times(eval_expr(left), eval_expr(right));
			case Expr.Div( left, right ):
				UObjectReferenceOperation.div(eval_expr(left), eval_expr(right));
			case Expr.EBucket( expr ):
				eval_expr(expr);
			case Expr.EString( str ):
				var obj = this.values.get(str);
				if(obj == null) {
					return UObjectReference.UClass(vm.classmap.get(str));
				}
				return obj;
			case Expr.EConstString( str ):
				UObjectReference.UString( str );
			case Expr.ENumber( str ):
				UObjectReference.UNumber( Std.parseFloat(str) );
			case Expr.ENew( name , params ):
				UObjectReference.UObject(this.vm.classmap.get(name).call_constructor(params));
			case Expr.ECall( left, name , params ):
				var input_params = new Array<UObjectReference>();
				for(p in params) {
					input_params.push(eval_expr(p));
				}
				return switch(eval_expr(left)) {
					case UObjectReference.UObject(object):
						return object.call(name, input_params);
					case UObjectReference.UClass(klass):
						return klass.call_static(name, input_params);
					default:
						null;
				}
			case Expr.EDot( left , right ):
				return switch(eval_expr(left)) {
					case UObjectReference.UObject(object):
						return eval_expr(right);
					default:
						null;
				}
			default:
				return null;
		}
	}}