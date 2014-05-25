package u.parser;

import u.parser.AST.Statement;
import u.parser.AST.Definition;
import u.parser.AST.Attr;
import u.parser.AST.Param;
import u.util.CallStack;

class Peg {

	private var text:String;
	private var savepoint:Array<String>;
	private var params:Array<Dynamic>;
	private var savepoint_params:Array<Dynamic>;
	private var log:Array<String>;
	private var callstack:CallStack;


	public function new() {
		this.savepoint = new Array<String>();
		this.params = new Array<Dynamic>();
		this.savepoint_params = new Array<Dynamic>();
		this.log = new Array<String>();
		this.callstack = new CallStack();
	}

	public function setText(text) {
		this.text = text;
	}

	public function getResult() {
		return this.params;
	}

	public function getText() {
		return this.text;
	}

	public function getLog() {
		return this.log;
	}

	public function getCallStack() {
		return this.callstack;
	}

	public function do_program() {
		this.callstack.call("program");
		if(do_statement() && do_program()) {
			var _program = this.params.pop();
			var _statement = this.params.pop();
			this.params.push(_program.concat([_statement]));
			return true;
		}
		return false;
	}

	public function do_statement() {
		var state = save_state();
		if(getKeyword() && do_word() && getChar("(") && do_params() && getChar(")") && getChar("{") && do_attrs() && getChar("}")) {
			var _attrs = this.params.pop();
			var _params = this.params.pop();
			var _words = this.params.pop();
			this.params.push(Statement.SDef(Definition.FunctionDefinition(_words, _params, _attrs)));
			this.callstack.ret();
			return true;
		}
		restore_state(state);
		if(do_words() && getChar("{") && do_attrs() && getChar("}")) {
			var _attrs = this.params.pop();
			var _words = this.params.pop();
			this.params.push(Statement.SDef(Definition.ClassDefinition(_words, _attrs)));
			return true;
		}
		restore_state(state);
		//expr statement
		if(do_expr_additive() && getChar(";")) {
			var _expr = this.params.pop();
			this.params.push(Statement.SExpr(_expr));
			return true;
		}
		restore_state(state);
		/*
		if(do_words_statement()) {
			this.params.push(Statement.SWords(this.params.pop()));
			return true;
		}
		*/
		this.log.push("not statement : " + this.text);
		return false;
	}

	public function do_words_statement() {
		if(do_words() && getChar(";")) {
			this.params.push(this.params.pop());
			return true;
		}
		this.log.push("not words statement : " + this.text);
		return false;
	}

	public function do_attrs() {
		var state = save_state();
		if(do_words_statement() && do_attrs()) {
			var _attrs = this.params.pop();
			var _attr = this.params.pop();
			this.params.push([_attr].concat(_attrs));
			return true;
		}
		restore_state(state);
		if(do_words_statement()) {
			var _attr = this.params.pop();
			this.params.push([_attr]);
			return true;
		}
		return false;
	}

	public function do_params() {
		var state = save_state();
		if(do_expr_additive() && getChar(",") && do_params()) {
			var _attrs = this.params.pop();
			var _attr = this.params.pop();
			this.params.push([_attr].concat(_attrs));
			return true;
		}
		restore_state(state);
		if(do_expr_additive()) {
			var _attr = this.params.pop();
			this.params.push([_attr]);
			return true;
		}
		this.log.push("not params : " + this.text);
		return false;
	}

	public function do_words() {
		var state = save_state();
		if(do_word() && do_words()) {
			var _words = this.params.pop();
			var _word = this.params.pop();
			this.params.push([_word].concat(_words));
			return true;
		}
		restore_state(state);
		if(do_word()) {
			var _word = this.params.pop();
			this.params.push([_word]);
			return true;
		}
		return false;
	}

	public function do_expr_additive() {
		var state = save_state();
		if(do_expr_multiplicative() && getChars("+-") && do_expr_additive()) {
			var _expr = this.params.pop();
			var _op = this.params.pop();
			var _word = this.params.pop();
			if(_op == "+") {
				this.params.push(Expr.Plus(_word, _expr));
			}else if(_op == "-") {
				this.params.push(Expr.Minus(_word, _expr));
			}
			return true;
		}
		restore_state(state);
		if(do_expr_multiplicative()) {
			var _expr = this.params.pop();
			this.params.push(_expr);
			return true;
		}
		this.log.push("not expr additive : " + this.text);
		return false;
	}
	public function do_expr_multiplicative() {
		var state = save_state();
		if(do_expr_primary() && getChars("*/") && do_expr_multiplicative()) {
			var _expr = this.params.pop();
			var _op = this.params.pop();
			var _word = this.params.pop();
			if(_op == "*") {
				this.params.push(Expr.Times(_word, _expr));
			}else if(_op == "/") {
				this.params.push(Expr.Div(_word, _expr));
			}
			return true;
		}
		restore_state(state);
		if(do_expr_primary()) {
			var _expr = this.params.pop();
			this.params.push(_expr);
			return true;
		}
		this.log.push("not expr multiplicative : " + this.text);
		return false;
	}
	public function do_expr_primary() {
		var state = save_state();
		if(do_word() && getChar("(") && do_params() && getChar(")")) {
			var _params = this.params.pop();
			var _call = this.params.pop();
			this.params.push(Expr.ECall(_call, _params));
			return true;
		}
		restore_state(state);
		if(do_word() && getChar("(") && getChar(")")) {
			var _call = this.params.pop();
			this.params.push(Expr.ECall(_call, new Array<Expr>()));
			return true;
		}
		restore_state(state);
		if( do_word() ) {
			var _word = this.params.pop();
			this.params.push(Expr.EString(_word));
			return true;
		}
		restore_state(state);
		if(getChar("(") && do_expr_additive() && getChar(")")) {
			var _expr = this.params.pop();
			this.params.push(Expr.EBucket(_expr));
			return true;
		}
		this.log.push("not expr primary : " + this.text);
		return false;
	}
	public function do_word() {
		var r : EReg = ~/^\w+/;
		if(r.match(this.text)) {
			this.params.push(r.matched(0));
			this.text = r.replace(this.text, "");
			spaces();
			return true;
		}
		return false;
	}

	public function getKeyword() {
		var r : EReg = ~/^function/;
		if(r.match(this.text)) {
			this.text = r.replace(this.text, "");
			spaces();
			return true;
		}
		return false;
	}

	public function getChar(c) {
		if(this.text.charAt(0) == c) {
			this.text = this.text.substr(1);
			spaces();
			return true;
		}
		return false;
	}

	public function getChars(cs:String) {
		if(this.text.length > 0 && cs.indexOf(this.text.charAt(0)) >= 0) {
			this.params.push(this.text.charAt(0));
			this.text = this.text.substr(1);
			spaces();
			return true;
		}
		return false;
	}

	public function save_state() {
		return {
			text : this.text,
			params : this.params.copy()
		}
	}

	public function restore_state(state) {
		this.text = state.text;
		this.params = state.params.copy();
	}

	public function spaces() {
		var cindex = 0;
		var c = this.text.charAt(cindex);
		while(c == " " || c == "\t") {
			c = this.text.charAt(++cindex);
		}
		this.text = this.text.substr(cindex);
		return true;
	}
}