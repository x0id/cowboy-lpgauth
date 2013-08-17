%% Feel free to use, reuse and abuse the code in this file.

-module(chunked_hello_world).

%% API.
-export([start/0]).

%% API.

start() ->
	ok = application:start(crypto),
	ok = application:start(barre),
	ok = application:start(cowboy),
	ok = application:start(chunked_hello_world).
