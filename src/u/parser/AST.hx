package u.parser;

enum Program {
	Statements(statements:Array<Statement>);
	None;
}

enum Statement {
	SExpr(expr:Expr);
	SReturn(expr:Expr);
	SRestriction(left:Array<String>, expr:Expr);
	SWords(words:Array<String>);
	SDefClass(left:Array<String>, attrs:Array<Attr>/*, methods:Array<MethodDefinition>*/);
	SDefFunction(name:String, params:Array<Param>, statements:Array<Statement>);
}

enum Definition {
}

enum MethodDefinition {
	MethodDefinition(name:String, params:Array<Expr>, statements:Array<Statement>);
}

enum Attr {
	AAttr(names:Array<String>);
}

enum Param {
	PParam(type:String, name:String);
}

