package u.parser;

import u.parser.AST.Statement;
import u.parser.AST.ClassElement;
import u.parser.AST.Attr;
import u.parser.AST.Param;
import u.parser.AST.Expr;
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
		var state = save_state();
		if(do_statement() && do_program()) {
			var _program = this.params.pop();
			var _statement = this.params.pop();
			this.params.push([_statement].concat(_program));
			return true;
		}
		restore_state(state);
		if(do_statement()) {
			var _statement = this.params.pop();
			this.params.push([_statement]);
			return true;
		}
		return false;
	}

	public function do_statement() {
		var state = save_state();
		if(getKeyword("if") && getChar("(") && do_expr_additive() && getChar(")") && getChar("{") && do_program() && getChar("}")) {
			var _program = this.params.pop();
			var _condition = this.params.pop();
			this.params.push(Statement.SIF(_condition, _program));
			this.callstack.ret();
			return true;
		}
		if(getKeyword("function") && do_word() && do_paramdefs_with_bucket() && getChar("{") && do_program() && getChar("}")) {
			var _attrs = this.params.pop();
			var _params = this.params.pop();
			var _name = this.params.pop();
			this.params.push(Statement.SDefFunction(_name, _params, _attrs));
			this.callstack.ret();
			return true;
		}
		restore_state(state);
		if(getKeyword("class") && do_class()) {
			var _class = this.params.pop();
			this.params.push(_class);
			return true;
		}
		restore_state(state);
		if(getKeyword("return") && do_expr_additive() && getChar(";")) {
			var _expr = this.params.pop();
			this.params.push(Statement.SReturn(_expr));
			return true;
		}
		restore_state(state);
		if(do_expr_additive() && getChar(";")) {
			var _expr = this.params.pop();
			this.params.push(Statement.SExpr(_expr));
			return true;
		}
		restore_state(state);
		if(do_expr_primary_dot() && getChar("=") && do_expr_additive() && getChar(";")) {
			var _expr = this.params.pop();
			var _words = this.params.pop();
			this.params.push(Statement.SRestriction(_words, _expr));
			return true;
		}
		restore_state(state);
		if(do_words() && getChar(";")) {
			this.params.push(Statement.SWords(this.params.pop()));
			return true;
		}
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

	public function do_class() {
		var state = save_state();
		if(do_word() && getChar("{") && getChar("}")) {
			var _word = this.params.pop();
			this.params.push(Statement.SDefClass(_word, []));
			return true;
		}
		restore_state(state);
		if(do_word() && getChar("{") && do_class_elements() && getChar("}")) {
			var _elems = this.params.pop();
			var _word = this.params.pop();
			this.params.push(Statement.SDefClass(_word, _elems));
			return true;
		}
		return false;
	}

	public function do_class_elements() {
		var state = save_state();
		if(do_method() && do_class_elements()) {
			var _attrs = this.params.pop();
			var _attr = this.params.pop();
			this.params.push([_attr].concat(_attrs));
			return true;
		}
		restore_state(state);
		if(do_attr() && do_class_elements()) {
			var _attrs = this.params.pop();
			var _attr = this.params.pop();
			this.params.push([_attr].concat(_attrs));
			return true;
		}
		restore_state(state);
		if(do_method()) {
			var _attr = this.params.pop();
			this.params.push([_attr]);
			return true;
		}
		return false;
	}

	public function do_attr() {
		var state = save_state();
		if(do_word() && do_word() && getChar(";")) {
			var _name = this.params.pop();
			var _type = this.params.pop();
			this.params.push(ClassElement.Attr(_type, _name));
			return true;
		}
		return false;
	}

	public function do_method() {
		var state = save_state();
		if(getKeyword("function") && do_word() && do_paramdefs_with_bucket() && getChar("{") && do_program() && getChar("}")) {
			var _attrs = this.params.pop();
			var _params = this.params.pop();
			var _name = this.params.pop();
			this.params.push(ClassElement.Method(_name, _params, _attrs));
			return true;
		}
		return false;
	}

	public function do_paramdefs_with_bucket() {
		var state = save_state();
		if(getChar("(") && do_paramdefs() && getChar(")")) {
			var _params = this.params.pop();
			this.params.push(_params);
			return true;
		}
		restore_state(state);
		if(getChar("(") && getChar(")")) {
			this.params.push([]);
			return true;
		}
		return false;
	}

	public function do_paramdefs() {
		var state = save_state();
		if(do_word() && do_word() && getChar(",") && do_paramdefs()) {
			var _attrs = this.params.pop();
			var _name = this.params.pop();
			var _type = this.params.pop();
			this.params.push([{ type : _type , name : _name }].concat(_attrs));
			return true;
		}
		restore_state(state);
		if(do_word() && do_word()) {
			var _name = this.params.pop();
			var _type = this.params.pop();
			this.params.push([{ type : _type , name : _name }]);
			return true;
		}
		this.log.push("not params : " + this.text);
		return false;
	}

	public function do_params_with_bucket() {
		var state = save_state();
		if(getChar("(") && do_params() && getChar(")")) {
			var _params = this.params.pop();
			this.params.push(_params);
			return true;
		}
		restore_state(state);
		if(getChar("(") && getChar(")")) {
			this.params.push([]);
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
		if(do_expr_comparison() && getChars("*/") && do_expr_multiplicative()) {
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
		if(do_expr_comparison()) {
			var _expr = this.params.pop();
			this.params.push(_expr);
			return true;
		}
		this.log.push("not expr multiplicative : " + this.text);
		return false;
	}
	public function do_expr_comparison() {
		var state = save_state();
		if(do_expr_primary_dot() && getChars("<>") && do_expr_comparison()) {
			var _expr = this.params.pop();
			var _op = this.params.pop();
			var _word = this.params.pop();
			if(_op == "<") {
				this.params.push(Expr.Lt(_word, _expr));
			}else if(_op == ">") {
				this.params.push(Expr.Gt(_word, _expr));
			}
			return true;
		}
		restore_state(state);
		if(do_expr_primary_dot() && getKeyword("<=") && do_expr_comparison()) {
			var _expr = this.params.pop();
			var _word = this.params.pop();
			this.params.push(Expr.Le(_word, _expr));
			return true;
		}
		restore_state(state);
		if(do_expr_primary_dot() && getKeyword(">=") && do_expr_comparison()) {
			var _expr = this.params.pop();
			var _word = this.params.pop();
			this.params.push(Expr.Ge(_word, _expr));
			return true;
		}
		restore_state(state);
		if(do_expr_primary_dot() && getKeyword("==") && do_expr_comparison()) {
			var _expr = this.params.pop();
			var _word = this.params.pop();
			this.params.push(Expr.Eq(_word, _expr));
			return true;
		}
		restore_state(state);
		if(do_expr_primary_dot() && getKeyword("!=") && do_expr_comparison()) {
			var _expr = this.params.pop();
			var _word = this.params.pop();
			this.params.push(Expr.Ne(_word, _expr));
			return true;
		}
		restore_state(state);
		if(do_expr_primary_dot()) {
			var _expr = this.params.pop();
			this.params.push(_expr);
			return true;
		}
		this.log.push("not expr multiplicative : " + this.text);
		return false;
	}
	public function do_expr_primary_dot() {
		var state = save_state();
		if(do_word() && getChar(".") && do_expr_primary()) {
			var _right = this.params.pop();
			var _left = this.params.pop();
			this.params.push(Expr.Member(_left, _right));
			return true;
		}
		restore_state(state);
		if(do_expr_primary()) {
			var _expr = this.params.pop();
			this.params.push(_expr);
			return true;
		}
		return false;
	}

	public function do_expr_primary() {
		var state = save_state();
		if(do_word() && do_params_with_bucket()) {
			var _params = this.params.pop();
			var _call = this.params.pop();
			//var _left = this.params.pop();
			this.params.push(Expr.ECall(null, _call, _params));
			return true;
		}
		restore_state(state);
		if(getKeyword("new") && do_word() && getChar("(") && getChar(")")) {
			var _call = this.params.pop();
			this.params.push(Expr.ENew(_call, new Array<Expr>()));
			return true;
		}
		restore_state(state);
		if( do_number() ) {
			var _word = this.params.pop();
			this.params.push(Expr.ENumber(_word));
			return true;
		}
		restore_state(state);
		if(getChar("\"") && do_word() && getChar("\"")) {
			var _word = this.params.pop();
			this.params.push(Expr.EConstString(_word));
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

	public function do_number() {
		var r : EReg = ~/^\d+/;
		if(r.match(this.text)) {
			this.params.push(r.matched(0));
			this.text = r.replace(this.text, "");
			spaces();
			return true;
		}
		return false;
	}

	public function getKeyword(keyword) {
		var r : EReg = new EReg("^"+keyword, "");
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