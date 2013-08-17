%% Copyright (c) 2011-2013, Loïc Hoguin <essen@ninenines.eu>
%%
%% Permission to use, copy, modify, and/or distribute this software for any
%% purpose with or without fee is hereby granted, provided that the above
%% copyright notice and this permission notice appear in all copies.
%%
%% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
%% WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
%% MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
%% ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
%% WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
%% ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
%% OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

%% @doc Convenience API to start and stop HTTP/HTTPS listeners.
-module(cowboy).

-export([start_http/4]).
-export([start_https/4]).
-export([start_spdy/4]).
-export([stop_listener/1]).
-export([set_env/3]).

-type http_headers() :: [{binary(), iodata()}].
-export_type([http_headers/0]).

-type http_status() :: non_neg_integer() | binary().
-export_type([http_status/0]).

-type http_version() :: 'HTTP/1.1' | 'HTTP/1.0'.
-export_type([http_version/0]).

-type onrequest_fun() :: fun((Req) -> Req).
-export_type([onrequest_fun/0]).

-type onresponse_fun() ::
	fun((http_status(), http_headers(), iodata(), Req) -> Req).
-export_type([onresponse_fun/0]).

%% @doc Start an HTTP listener.
-spec start_http(barrel:ref(), non_neg_integer(), barrel_tcp:opts(),
	cowboy_protocol:opts()) -> {ok, pid()} | {error, any()}.
start_http(Ref, NbAcceptors, TransOpts, ProtoOpts)
		when is_integer(NbAcceptors), NbAcceptors > 0 ->
	barrel:start_listener(Ref, NbAcceptors,
		barrel_tcp, TransOpts, cowboy_protocol, ProtoOpts).

%% @doc Start an HTTPS listener.
-spec start_https(barrel:ref(), non_neg_integer(), barrel_ssl:opts(),
	cowboy_protocol:opts()) -> {ok, pid()} | {error, any()}.
start_https(Ref, NbAcceptors, TransOpts, ProtoOpts)
		when is_integer(NbAcceptors), NbAcceptors > 0 ->
	barrel:start_listener(Ref, NbAcceptors,
		barrel_ssl, TransOpts, cowboy_protocol, ProtoOpts).

%% @doc Start a SPDY listener.
-spec start_spdy(barrel:ref(), non_neg_integer(), barrel_ssl:opts(),
	cowboy_spdy:opts()) -> {ok, pid()} | {error, any()}.
start_spdy(Ref, NbAcceptors, TransOpts, ProtoOpts)
		when is_integer(NbAcceptors), NbAcceptors > 0 ->
	TransOpts2 = [
		{connection_type, supervisor},
		{next_protocols_advertised,
			[<<"spdy/3">>, <<"http/1.1">>, <<"http/1.0">>]}
	|TransOpts],
	barrel:start_listener(Ref, NbAcceptors,
		barrel_ssl, TransOpts2, cowboy_spdy, ProtoOpts).

%% @doc Stop a listener.
-spec stop_listener(barrel:ref()) -> ok.
stop_listener(Ref) ->
	barrel:stop_listener(Ref).

%% @doc Convenience function for setting an environment value.
%%
%% Allows you to update live an environment value used by middlewares.
%% This function is primarily intended to simplify updating the dispatch
%% list used for routing.
-spec set_env(barrel:ref(), atom(), any()) -> ok.
set_env(Ref, Name, Value) ->
	{Handler, Opts} = barrel:get_protocol_conf(Ref),
	{_, Env} = lists:keyfind(env, 1, Opts),
	Env2 = [{Name, Value}|lists:keydelete(Name, 1, Env)],
	Opts2 = lists:keyreplace(env, 1, Opts, {env, Env2}),
	ok = barrel:set_protocol_conf(Ref, Handler, Opts2).
