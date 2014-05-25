package u.util;

class CallStack {
	private var callstack:Map<String, Dynamic>;
	private var current_call:Map<String, Dynamic>;
	private var indent = 0;

	public function new() {
		this.callstack = new Map<String, Dynamic>();
		this.current_call = new Map<String, Dynamic>();
		this.current_call = this.callstack;
	}

	public function call(method:String) {
		indent++;
		trace(getIndent() + method, "Called");
	}

	public function log(mes:String) {
		trace(getIndent() + mes);
	}

	public function ret() {
		indent--;
	}

	public function getIndent() {
		var space = "";
		for(i in 0...indent) {
			space += "  ";
		}
		return space;
	}

	public function view() {
		view_part(this.callstack);
	}

	public function view_part(p:Map<String, Dynamic>) {
		for(pp in p.keys()) {
			//trace(pp);
		}
		for(pp in p) {
			this.view_part(pp);
		}
	}
}