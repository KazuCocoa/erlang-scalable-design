% don't sufficient.
-module (coffee_fsm).
-behaviour (gen_fsm).

-export ([start_link/0, start_link/2, start/2, stop/0]).
-export ([init/1, terminate/3]).
-export ([tea/0, espresso/0, americano/0, cappuccino/0, pay/1, cup_removed/0, cancel/0]). %% Client Functions for events

start_link() ->
  gen_fsm:start_link({local, ?MODULE}, ?MODULE, [], []).

start_link(TimerMs, Options) ->
  gen_fsm:start_link(?MODULE, TimerMs, Options).
start(TimerMs, Options) ->
  gen_fsm:start(?MODULE, TimerMs, Options).

init(0) ->
  {stop, stopped};
init(1) ->
  {next_state, selection, []};
init(TimerMs) ->
  timer:sleep(TimerMs),
  ignore;
init([]) ->
  hw:reboot(),
  hw:display("Make Your Selection", []),
  process_flag(trap_exit, true),
  {ok, selection, []}.

stop() ->
  gen_fsm:sync_send_all_state_event(?MODULE, stop).
handle_event(stop, State, LoopData) ->
  {stop, normal, LoopData}.

terminate(_Reason, payment, {_Type, _Price, Paid}) ->
  hw:return_change(Paid);
terminate(_Reason, _StateName, _LoopData) ->
  ok.


%% Client Functions for Drnk Selections
tea() ->
  gen_fsm:send_event(?MODULE, {selection, tea, 100}).
espresso() ->
  gen_fsm:send_event(?MODULE, {selection, espresso, 150}).
americano() ->
  gen_fsm:send_event(?MODULE, {selection, americano, 100}).
cappuccino() ->
  gen_fsm:send_event(?MODULE, {selection, cappuccino, 150}).

%% Client Functions for Actions
cup_removed() ->
  gen_fsm:send_event(?MODULE, cup_removed).
pay(Coin) ->
  gen_fsm:send_event(?MODULE, {pay, Coin}).
cancel() ->
  gen_fsm:send_event(?MODULE, cancel).

%% State: drink selection[]
selection({selection, Type, Price}, _LoopData) ->
  hw:display("Please pay:~w", [Price]),
  {next_state, payment, {Type, Price, 0}};
selection({pay, Coin}, LoopData) ->
  hw:return_change(coin),
  {next_state, selection, LoopData};
selection(_Other, LoopData) ->
  {next_state, selection, LoopData}.

selection() ->
  receive
    {selection, Type, Price} ->
      hw:display("Please pay:~w", [Price]),
      payment(Type, Price, 0);
    {pay, Coin} ->
      hw:return_change(Coin),
      selection;
    _Other -> % cancel
      selection()
  end.

%% State: payment
payment(Type, Price, Paid) ->
  receive
    {Pay, Coin} ->
      if
        Coin + Paid >= Price ->
          hw:display("Preparing Drink.", []),
          hw:return_change(Coin + Paid - Price),
          hw:drop_cup(), hw:prepare(Type),
          hw:display("Remove Drink.", []),
          remove();
        true ->
          ToPay = Price - (Coin + Paid),
          hw:display("Please pay:~w", [ToPay]),
          payment(Type, Price, Coin + Paid)
        end;
    cancel ->
      hw:display("Make Your Selection", []),
      hw:return_change(Paid),
      selection();
    _Other -> % selection
      payment(Type, Price, Paid)
  end.

remove() ->
  receive
    cup_removed ->
      hw:display("Make Your Selection", []),
      selection();
    {pay, Coin} ->
      hw:return_change(Coin),
      remove();
    Other -> %  cancel/selection
      remove()
  end.
