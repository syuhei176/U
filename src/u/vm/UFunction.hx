package u.vm;

import u.parser.AST;
import u.parser.AST.Expr;
import u.vm.UObjectReference;

class UFunction {

	private var values:Map<String, UObjectReference>;
	
	private var functionmap:Map<String, UFunction>;
	private var classmap:Map<String, UClass>;
	var name:String;
	var params:Array<Param>;
	var statements:Array<Statement>;
	private var vm:Vm;
	private var return_obj:UObjectReference;

	public function new(vm, name, params, statements) {
		this.vm = vm;
		this.name = name;
		this.params = params;
		this.statements = statements;
		this.values = new Map<String, UObjectReference>();
		this.functionmap = new Map<String, UFunction>();
		this.classmap = new Map<String, UClass>();
		this.return_obj = null;
	}

	public function clone() {
		return new UFunction(vm, name, params, statements);
	}

	public function eval(input_params:Array<UObjectReference>):UObjectReference {
		var i=0;
		for(p in this.params) {
			switch(p) {
				case { type : _type , name : _name }:
					this.values.set(_name, input_params[i]);
			}
			i++;
		}
		this.eval_program(this.statements);
		return this.return_obj;
	}

	public function set_self(self:UObjectReference) {
		this.values.set("this", self);
	}

	public function eval_program(statements:Array<Statement>) {
		for(s in statements) {
			if(s != null) {
				var r = eval_statement(s);
				if(this.return_obj != null) {
					return;
				}
			}
		}
	}

	public function do_return(objref:UObjectReference) {
		this.return_obj = objref;
	}

	public function eval_statement(statement:Statement):UObjectReference {
		return switch(statement) {
			case Statement.SIF( condition , statements ):
				if(switch(eval_expr(condition)){case UObjectReference.UBool( b ):b;default:false;}) {
					eval_program(statements);
					null;
				}else
					null;
			case Statement.SExpr( expr ):
				eval_expr(expr);
				null;
			case Statement.SReturn( expr ):
				do_return(eval_expr(expr));
				null;
			case Statement.SWords( words ):
				null;
			case Statement.SRestriction( left , expr ):
				//this.values.set(left, eval_expr(expr));
				this.assignment_expr(left, eval_expr(expr));
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

	public function assignment_expr(expr:Expr, obj:UObjectReference) {
		return switch(expr) {
			case Expr.Member( left, right ):
				member_expr(left, right, obj);
			case Expr.EString( str ):
				this.values.set(str, obj);
			default:
		}
	}

	public function member_expr(left:String, right:Expr, obj) {
		return switch(right) {
			case Expr.EString( str2 ):
				return switch(this.values.get(left)) {
					case UObjectReference.UObject( object ):
						object.set(str2, obj);
					default:
						null;
				}
			default:
		}
	}

	public function eval_expr(expr:Expr, ?base):UObjectReference {
		return switch(expr) {
			case Expr.Member( left, right ):
				eval_expr(right, left);
			case Expr.Plus( left, right ):
				UObjectReferenceOperation.plus(eval_expr(left), eval_expr(right));
			case Expr.Minus( left, right ):
				UObjectReferenceOperation.minus(eval_expr(left), eval_expr(right));
			case Expr.Times( left, right ):
				UObjectReferenceOperation.times(eval_expr(left), eval_expr(right));
			case Expr.Div( left, right ):
				UObjectReferenceOperation.div(eval_expr(left), eval_expr(right));
			case Expr.Eq( left, right ):
				UObjectReferenceOperation.eq(eval_expr(left), eval_expr(right));
			case Expr.Le( left, right ):
				UObjectReferenceOperation.le(eval_expr(left), eval_expr(right));
			case Expr.EBucket( expr ):
				eval_expr(expr);
			case Expr.EString( str ):
				if(base == null) {
					var obj = this.values.get(str);
					if(obj == null) {
						return UObjectReference.UClass(vm.classmap.get(str));
					}
					return obj;
				}else{
					var obj = this.values.get(base);
					switch (obj) {
						case UObjectReference.UObject( object ):
							return object.get(str);
						default:
							null;
					}
				}
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
				if(base == null) {
					return switch(eval_expr(left)) {
						case UObjectReference.UObject(object):
							return object.call(name, input_params);
						case UObjectReference.UClass(klass):
							return klass.call_static(name, input_params);
						default:
							null;
					}
				}else{
					return switch(eval_expr(Expr.EString(base))) {
						case UObjectReference.UObject(object):
							return object.call(name, input_params);
						case UObjectReference.UClass(klass):
							return klass.call_static(name, input_params);
						default:
							null;
					}
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