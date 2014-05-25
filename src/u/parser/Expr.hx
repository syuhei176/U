package u.parser;

enum Expr {
	Plus(left:Expr, right:Expr);
	Minus(left:Expr, right:Expr);
	Times(left:Expr, right:Expr);
	Div(left:Expr, right:Expr);
	Other(left:Expr, op:String, right:Expr);
	EString(str:String);
	EBucket(expr:Expr);
	ECall(name:String, params:Array<Expr>);
	Error(mes:String);
}
