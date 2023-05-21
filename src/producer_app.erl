%%%-------------------------------------------------------------------
%% @doc producer public API
%% @end
%%%-------------------------------------------------------------------

-module(producer_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    producer_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
