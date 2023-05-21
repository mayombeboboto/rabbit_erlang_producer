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
-export([publish/2]).

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
    publish(?ROUTING_KEY, Payload).

-spec publish(binary(), #{}) -> no_return().
publish(RoutingKey, Payload) ->
    gen_server:cast(?MODULE, {publish, RoutingKey, jsx:encode(Payload)}).

%%%-------------------------------------------------------------------
%%% Callback Functions
%%%-------------------------------------------------------------------
init(null) ->
    process_flag(trap_exit, true),
    self() ! ?FUNCTION_NAME,
    {ok, #{}}.

handle_call(_Msg, _From, State) ->
    {reply, ok, State}.

handle_cast({publish, RoutingKey, Payload}, State=#{ channel := Channel }) ->
    Publish =#'basic.publish'{ mandatory=true,
                               exchange=?EXCHANGE,
                               routing_key=RoutingKey },
    Headers = [{<<"company">>, binary, <<"Kuantic">>},
               {<<"position">>, binary, <<"Contractor">>}],
    Props = #'P_basic'{ delivery_mode = ?PERSISTENT_DELIVERY,
                        content_type = <<"application/json">>,
                        message_id = generate_msg_id(),
                        timestamp = time_since_epoch(),
                        headers = Headers },
    amqp_channel:cast(Channel, Publish, #amqp_msg{ props=Props, payload=Payload }),
    {noreply, State}.

handle_info(init, _State) ->
    {ok, Connection} = amqp_connection:start(#amqp_params_network{}),
    {ok, Channel} = amqp_connection:open_channel(Connection),
    amqp_channel:register_return_handler(Channel, self()),

    ExchangeDeclare = #'exchange.declare'{ exchange = ?EXCHANGE },
    #'exchange.declare_ok'{} = amqp_channel:call(Channel, ExchangeDeclare),

    QueueDeclare = #'queue.declare'{ queue = ?QUEUE },
    #'queue.declare_ok'{} = amqp_channel:call(Channel, QueueDeclare),

    Binding = #'queue.bind'{ queue =?QUEUE,
                             exchange=?EXCHANGE,
                             routing_key=?ROUTING_KEY },
    #'queue.bind_ok'{} = amqp_channel:call(Channel, Binding),
    {noreply, #{ channel => Channel }};
handle_info({#'basic.return'{}, #amqp_msg{ payload=Payload }}, State) ->
    io:format("Info: ~p~n", [jsx:decode(Payload)]),
    {noreply, State}.

terminate(_Reason, _State) -> ok.

%%%-------------------------------------------------------------------
%%% Internal Functions
%%%-------------------------------------------------------------------
generate_msg_id() ->
    list_to_binary(uuid:uuid_to_string(uuid:get_v4())).

time_since_epoch() ->
    Now = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
    Now * 1000.