U
=

A programing language.


#Usage

    haxe build.hxml
    neko u.n sample.u


define,create,select,observe

##define

name {
	attrs,
}

Book {
	String title;
}

add(a, b) {
	return a + b;
}

fib(0) = 1;
fib(1) = 1;

##create

{Class} {params}

##select

{Class} {selector}
select Book(this.registerd > new Date());

##observe

observe Book {
	update(v) {
		print v;
	}
}

Book.title.change() {
	
}

