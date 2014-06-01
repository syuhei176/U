package u.parser;

enum Expr {
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
