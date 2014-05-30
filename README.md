U
=

A programing language.


#Usage

    haxe build.hxml
    neko u.n samples/cal.u



var b = 1;
var a = func(b);

var actor = new Actor();
actor var obj = new Object();
obj.call()
データを永続化させるノードは決まっている。
複数ノードで計算を行う。
通信路が暗号化され十分に抽象化されていれば、セキュリティなんていらないのではないか。

標準入力と標準出力
var input = Sys("client1").input();
var line = input.readLine();
var input = Sys("server1").input();
var line = input.readLine();

オブジェクトはnewされた場所にある。
var book = new Book
メソッド呼び出しは通信である。
