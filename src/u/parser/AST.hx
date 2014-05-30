package u.parser;

enum AST {

}

enum Program {
	Statements(statements:Array<Statement>);
	None;
}

enum Statement {
	SExpr(expr:Expr);
	SReturn(expr:Expr);
	SRestriction(left:Array<String>, expr:Expr);
	SWords(words:Array<String>);
	SDefClass(name:String, elems:Array<ClassElement>);
	SDefFunction(name:String, params:Array<Param>, statements:Array<Statement>);
}

enum ClassElement {
	Attr(type:String, name:String);
	Method(name:String, params:Array<Param>, statements:Array<Statement>);
}

typedef Attr = {
	type:String,
	name:String
}

typedef Method = {
	type:String,
	name:String,
	params:Array<Expr>,
	statements:Array<Statement>
}

typedef Param = {
	type:String,
	name:String
}

