package ;

import sys.io.File;
import sys.io.FileInput;
import u.parser.Parser;

class Main {
	static public function main() {
		if(Sys.args().length == 0) {
			shell();
		}else{
			readfile(Sys.args()[0]);
		}
	}

	static public function shell() {
		var parser = new Parser();
		var input = Sys.stdin();
		while(true) {
			var line = input.readLine();
			if(line == "exit") {
				return;
			}
			var result = parser.parse_main(line);
			trace(result);
		}
	}

	static public function readfile(path) {
		var parser = new Parser();
		var fi = File.read(path);
		var text = "";
		while(!fi.eof()) {
			text += fi.readLine();
		}
		var result = parser.parse_main(text);
		trace(result);
	}
}
