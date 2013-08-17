%% Feel free to use, reuse and abuse the code in this file.

-module(echo_get).

%% API.
-export([start/0]).

%% API.

start() ->
	ok = application:start(crypto),
	ok = application:start(barrel),
	ok = application:start(cowboy),
	ok = application:start(echo_get).
