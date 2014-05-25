package u.parser;

class Parser {

	public function new() {

	}

	public function parse_main(text:String):Dynamic {

		var peg = new Peg();
		peg.setText(text);
		if(peg.do_statement()) {
			return peg.getResult();
		}
		return {log : peg.getLog(), callstack : peg.getCallStack(), result:peg.getResult(), left : peg.getText()};
	}

}