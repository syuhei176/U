package u.parser;

enum AST {

}

enum Program {
	Statements(statements:Array<Statement>);
	None;
}

enum Statement {
	SIF(condition:Expr, statements:Array<Statement>);
	SExpr(expr:Expr);
	SReturn(expr:Expr);
	SRestriction(left:Expr, expr:Expr);
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

enum Expr {
	Member(left:String, right:Expr);
	Plus(left:Expr, right:Expr);
	Minus(left:Expr, right:Expr);
	Times(left:Expr, right:Expr);
	Div(left:Expr, right:Expr);
	Gt(left:Expr, right:Expr);
	Lt(left:Expr, right:Expr);
	Ge(left:Expr, right:Expr);
	Le(left:Expr, right:Expr);
	Eq(left:Expr, right:Expr);
	Ne(left:Expr, right:Expr);
	Other(left:Expr, op:String, right:Expr);
	EConstString(str:String);
	EString(str:String);
	ENumber(str:String);
	EBucket(expr:Expr);
	ECall(left:Expr, name:String, params:Array<Expr>);
	ENew(name:String, params:Array<Expr>);
	EDot(left:Expr, right:Expr);
	Error(mes:String);
}

enum Literal{

}