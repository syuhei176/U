package u.parser;

enum Program {
	Statements(statements:Array<Statement>);
	None;
}

enum Statement {
	SExpr(expr:Expr);
	SRestriction(left:Array<String>, expr:Expr);
	SWords(words:Array<String>);
	SDef(definition:Definition);
}

enum Definition {
	ClassDefinition(left:Array<String>, attrs:Array<Attr>/*, methods:Array<MethodDefinition>*/);
	FunctionDefinition(left:Array<String>, params:Array<Param>, statements:Array<Statement>);
}

enum MethodDefinition {
	MethodDefinition(left:Array<String>, params:Array<Expr>, statements:Array<Statement>);
}

enum Attr {
	AAttr(names:Array<String>);
}

enum Param {
	PParam(names:Array<String>);
}

