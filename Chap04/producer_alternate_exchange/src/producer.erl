%%%-------------------------------------------------------------------
%% @doc producer server.
%% @end
%%%-------------------------------------------------------------------
-module(producer).
%%%-------------------------------------------------------------------
-behaviour(gen_server).
%%%-------------------------------------------------------------------
-export([start_link/0]).
-export([publish/1]).

-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
%%%-------------------------------------------------------------------
-include_lib("amqp_client/include/amqp_client.hrl").
-include("../include/producer.hrl").

-define(PERSISTENT_DELIVERY, 2).
%%%-------------------------------------------------------------------
%%% API Functions
%%%-------------------------------------------------------------------
-spec start_link() -> {ok, pid()}.
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, null, []).

-spec publish(#{}) -> no_return().
publish(Payload) ->
    gen_server:cast(?MODULE, {publish,jsx:encode(Payload)}).

%%%-------------------------------------------------------------------
%%% Callback Functions
%%%-------------------------------------------------------------------
init(null) ->
    process_flag(trap_exit, true),
    self() ! ?FUNCTION_NAME,
    {ok, #{}}.

handle_call(_Msg, _From, State) ->
    {reply, ok, State}.

handle_cast({publish, Payload}, State=#{ channel := Channel }) ->
    Headers = [{<<"company">>, binary, <<"StarTech">>}],

    Publish =#'basic.publish'{ exchange=?EXCHANGE2,
                               % The routing_key must be already bound
                               % An exchange.
                               routing_key=?ROUTING_KEY1 },
    Props = #'P_basic'{ content_type = ?CONTENT_TYPE,
                        message_id = generate_msg_id(),
                        timestamp = time_since_epoch(),
                        headers = Headers },
    amqp_channel:cast(Channel, Publish, #amqp_msg{ props=Props, payload=Payload }),
    {noreply, State}.

handle_info(init, _State) ->
    {ok, Connection} = amqp_connection:start(#amqp_params_network{}),
    {ok, Channel} = amqp_connection:open_channel(Connection),

    ExchangeDeclare1 = #'exchange.declare'{ exchange = ?EXCHANGE1 },
    #'exchange.declare_ok'{} = amqp_channel:call(Channel, ExchangeDeclare1),

    ExchangeDeclare2 = #'exchange.declare'{ arguments= [{"alternate-exchange", longstr, ?EXCHANGE1}],
                                            exchange = ?EXCHANGE2 },
    #'exchange.declare_ok'{} = amqp_channel:call(Channel, ExchangeDeclare2),

    QueueDeclare1 = #'queue.declare'{ queue = ?QUEUE1 },
    #'queue.declare_ok'{} = amqp_channel:call(Channel, QueueDeclare1),

    QueueDeclare2 = #'queue.declare'{ queue = ?QUEUE2 },
    #'queue.declare_ok'{} = amqp_channel:call(Channel, QueueDeclare2),

    Binding1 = #'queue.bind'{ queue =?QUEUE1,
                              exchange=?EXCHANGE1,
                              routing_key=?ROUTING_KEY1 },
    #'queue.bind_ok'{} = amqp_channel:call(Channel, Binding1),

    Binding2 = #'queue.bind'{ queue =?QUEUE2,
                              exchange=?EXCHANGE2,
                              routing_key=?ROUTING_KEY2 },
    #'queue.bind_ok'{} = amqp_channel:call(Channel, Binding2),
    {noreply, #{ channel => Channel }};
handle_info({#'basic.return'{}, #amqp_msg{ payload=Payload, props=_Headers }}, State) ->
    Message = "Basic return\nPayload: ~p~n",
    io:format(Message, [jsx:decode(Payload)]),
    {noreply, State};
handle_info(Info, State) ->
    io:format("Info: ~p~n", [Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

%%%-------------------------------------------------------------------
%%% Internal Functions
%%%-------------------------------------------------------------------
generate_msg_id() ->
    list_to_binary(uuid:to_string(uuid:uuid4())).

time_since_epoch() ->
    Now = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
    Now * 1000.