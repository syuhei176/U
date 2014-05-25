package u.parser;

class Silv {
	static public function Compile() {
			var compiler = new Silv.Compiler();
			if(values) {
				for(var name in values) {
					compiler.addSystemValue(name, values[name]);
				}
			}
			compiler.addLibrary(library.numcheck);
			var func = compiler.CompileToFunction(script);
			return new Silv.CompiledScript(func);
	}

	public function CompiledScript(_func) {
		var func = _func;
		return {
			Exec : function(model) {
				return func(model);
			},
			getFunction : function() {
				return func;
			}
		}
	}

	public function to_text(input) {
        if(input == null || input === undefined)
            return '';
        if(input instanceof Date)
                    return input.toDateString();
            if(input.toString) 
            return input.toString();
            return '';
	}

}

class Compiler {
	public function init() {
		
	}
}

(function () {
	Silv.Compiler = function(){
		var system_values = {};
		var libs = [];
		var resultScript = "";
		
		var left = "<";
		var right = ">";
        var left_delimiter = left +'%';
        var right_delimiter = '%'+right;
        var double_left = left+'%%';
        var double_right = '%%'+right;
        var left_equal = left+'%=';
        var left_minus = left+'%-';
        var left_comment = left+'%#';
		var SplitRegexp = new RegExp('('+double_left+')|(%%'+double_right+')|('+left_equal+')|('+left_minus+')|('+left_comment+')|('+left_delimiter+')|('+right_delimiter+'\n)|('+right_delimiter+')|(\\\\)|(\n)') ;
		var lines = 0;
		function startOfFile(name) {
			resultScript += "__output=[];\n";
			resultScript += "var current_file={name:"+name+",content:''};\n";
			resultScript += "__files.push(current_file);\n";
		}
		function endOfFile() {
			resultScript += 'current_file.content+=__output.join("");\n';
		}
		var _buf_line = [];
		function push_to_buffer(cmd) {
			_buf_line.push(cmd);
		}
		function cr_buffer() {
			resultScript = resultScript + _buf_line.join("; ");
			_buf_line = [];
			resultScript = resultScript + "__stack.lineno="+lines+"\n";
		}
		function close_buffer() {
	        if (_buf_line.length > 0) {
	        	resultScript = resultScript + _buf_line.join('; ') + ";";
	        	_buf_line = null;
	        }
		}
		return {
			addLibrary : function(lib) {
				libs.push(lib);
			},
			addSystemValue : function(name, value) {
				system_values[name] = value;
			},
			CompileToFunction : function(script) {
				//script to resultScript
				var magic = "var window = {}, alert = {}, location = {}, open = {}, document = {}, g_wb = {}, g_editor = {};\n";
				resultScript = magic;
				//start of 環境変数追加
				for(var name in system_values) {
					resultScript += "var " + name + " = \"" + system_values[name] + "\";\n";
				}
				//end of 環境変数追加
				resultScript += "var __output = [];\n";
				resultScript += "var __files = [];\n";
				resultScript += "var __stack = {lineno:0};\n";
				resultScript += "var __error = {err : false, messages : []};\n";
				resultScript += "function error(message) {__error.err=true;__error.messages.push({level : 3, message : message});}";
				resultScript += "function warn(message) {__error.messages.push({level : 2, message : message});}";
				resultScript += "function info(message) {__error.messages.push({level : 1, message : message});}";
				resultScript += "try {";
				this.compile(script);
				resultScript += "}catch(e){";
				resultScript += "e.lineNumber = __stack.lineno + 1;";
				resultScript += "throw e;";
				resultScript += "}"
				resultScript += "return {output:__output.join(''),files:__files,status:__error};";
				//start of ライブラリコードの追加
				for(var i=0;i < libs.length;i++) {
					resultScript += libs[i].script + "\n";
				}
				//end of ライブラリコードの追加
				//console.log(resultScript);
				return new Function("_", resultScript);
			},
			compile : function(script) {
				//CR、CR・LF、LF改行コードをLFにする
				script = script.replace(/\r\n?/g,"\n");
				var clean = function(content) {
		            content = content.replace(/\\/g, '\\\\');
			        content = content.replace(/\n/g, '\\n');
			        content = content.replace(/"/g,  '\\"');
			        return content;
		        };
		        var put_cmd = "__output.push(";
		        var insert_cmd = put_cmd;
				var stag = null;
				var _is_escape_br = false;
				var content = "";
				this.parse(script, function(token){
					//console.log(token);
					if (stag == null) {
		                        switch(token) {
		                        	case '\\':
		                        		push_to_buffer(put_cmd + '"' + clean(content) + '");');
		                        		cr_buffer();
		                        		content = '';
		                        		_is_escape_br = true
		                        		break;
	                                case '\n':
	                                    if(_is_escape_br) {
	                                    	_is_escape_br = false;
	                                    }else{
	                                    	content = content + "\n";
	                                    	push_to_buffer(put_cmd + '"' + clean(content) + '");');
	                                    	cr_buffer();
	                                    	content = '';
	                                    }
	                                    break;
		                            case left_delimiter:
		                            case left_equal:
		                            case left_minus:
		                            case left_comment:
		                                    stag = token;
		                                    if (content.length > 0) {
		                                    	push_to_buffer(put_cmd + '"' + clean(content) + '")');
		                                    }
		                                    content = '';
		                                    break;
		                            case double_left:
		                                    content = content + left_delimiter;
		                                    break;
		                            default:
		                                    content = content + token;
		                                    break;
		                        }
		                } else {
		                        switch(token) {
	                                case right_delimiter:
	                                    switch(stag) {
	                                            case left_delimiter:
	                                                    if (content[content.length - 1] == '\n') {
	                                                            content = chop(content);
	                                                            push_to_buffer(content);
	                                                            cr_buffer();
	                                                    } else {
	                                                    	push_to_buffer(content);
	                                                    }
	                                                    break;
	                                            case left_equal:
	                                            	push_to_buffer(insert_cmd + "(Silv.to_text(" + content + ")))");
	                                                    break;
	                                            case left_minus:
	                                            	if(trim(content).indexOf("file") == 0) {
	                                            		var filename = trim(trim(content).slice(4));
	                                            		//console.log("file", filename);
	                                            		startOfFile(filename);
	                                            	}else if(trim(content).indexOf("endfile") == 0) {
		                                            		//var filename = trim(trim(content).slice(4));
		                                            		//console.log("endfile", filename);
		                                            		endOfFile(filename);
	                                            	}else{
	                                            		
	                                            	}
	                                            	//push_to_buffer(insert_cmd + "(Silv.to_text(" + content + ")))");
	                                                    break;
	                                    }
	                                    stag = null;
	                                    content = '';
	                                    break;
		                            case double_right:
		                                    content = content + right_delimiter;
		                                    break;
		                            default:
		                                    content = content + token;
		                                    break;
		                        }
		                }
				});
		        if (content.length > 0) {
		        	push_to_buffer(put_cmd + '"' + clean(content) + '")');
		        }
		        close_buffer();
			},
			parse : function(str, block) {
				var self = this;
				if (!str == '') {
					lines = 0;
					var source_split = rsplit(str, /(\n)/);
					for(var i=0; i<source_split.length; i++) {
						var item = source_split[i];
						parseline(item, SplitRegexp, block);
					}
				}
				function parseline(line, regex, block) {
					//console.log(line.indexOf("\n"));
					if(line.indexOf("\n") >= 0) lines++;
					var line_split = rsplit(line, regex);
					for(var i=0; i<line_split.length; i++) {
						var token = line_split[i];
						if (token != null) {
							try{
								block(token);
				            }catch(e){
				            	console.error(e);
				            	throw {type: 'EJS.Scanner', line: lines};
				            }
						}
					}
				}
			},
			readTag : function(args) {
				//console.log("tag", args);
				if(args[0] == "foreach") {
					resultScript += "for(var "+args[1]+"key in " + args[3] + "){";
					resultScript += "var "+args[1]+" = "+args[3]+"["+args[1]+"key];";
					//writeTo2("foreach");
				}else if(args[0] == "if") {
					resultScript += "if("+args[1]+args[2]+args[3]+"){";
				}else if(args[0] == "file") {
					startOfFile(args[1]);
				}
			},
			closeTag : function(tagName) {
				if(tagName == "foreach") {
					resultScript += "}";
				}else if(tagName == "if") {
					resultScript += "}";
				}else if(tagName == "file") {
					endOfFile();
				}
			},
			getCompiledScript : function() {
				return resultScript;
			}
		}
	}
	
	var library = {
			semanticcheck : {
				script : "function scheck() {}"
			},
			numcheck : {
				script : "\nfunction ncheck(_sys_meta, op, num) {" +
						"\n var count = 0;" +
						"\n ncheck_part(_)" +
						"\n if(op == '==' || op == '=') {" +
						"\n  return num == count;" +
						"\n }else if(op == '!=') {" +
						"\n  return count != num;" +
						"\n }else if(op == '<') {" +
						"\n  return count < num;" +
						"\n }else if(op == '>') {" +
						"\n  return count > num;" +
						"\n }else if(op == '<=') {" +
						"\n  return count <= num;" +
						"\n }else if(op == '>=') {" +
						"\n  return count >= num;" +
						"\n }" +
						"\n function ncheck_part(m) {" +
						"\n  if(m._sys_meta && cut_sys_meta(m._sys_meta) == _sys_meta) count++;" +
						"\n  for(var key in m) {" +
						"\n   if(m[key] && typeof m[key] == 'object') ncheck_part(m[key]);" +
						"\n  }" +
						"\n}" +
						"\nfunction cut_sys_meta(_sys_meta){" +
						"\nreturn _sys_meta.substr(_sys_meta.indexOf(\".\")+1);" +
						"\n}" +
						"\n}"
			},
			dictionarycheck : {
				script : "function dcheck() {}"
			}
	};
	
	var rsplit = function(string, regex) {
        var result = regex.exec(string),retArr = new Array(), first_idx, last_idx, first_bit;
        while (result != null)
        {
                first_idx = result.index; last_idx = regex.lastIndex;
                if ((first_idx) != 0)
                {
                        first_bit = string.substring(0,first_idx);
                        retArr.push(string.substring(0,first_idx));
                        string = string.slice(first_idx);
                }               
                retArr.push(result[0]);
                string = string.slice(result[0].length);
                result = regex.exec(string);    
        }
        if (! string == '')
        {
                retArr.push(string);
        }
        return retArr;
	},
	chop =  function(string){
		return string.substr(0, string.length - 1);
	},
	extend = function(d, s){
	    for(var n in s){
	        if(s.hasOwnProperty(n))  d[n] = s[n]
	    }
	},
	trim = function(target) {
		target = target.replace(/(^\s+)|(\s+$)/g, "");
		return target;
	}
	
}());
