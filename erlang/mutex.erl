
-module (mutex).
-export ([start_link/1, start_link/2, init/3, stop/1]).
-export ([wait/1, signal/1]).
-export ([system_continue/3, system_terminate/4]).

wait(Name) ->
  Name ! {wait, self()},
  Mutex = whereis(Name),
  receive
    {Mutex, ok} -> ok
  end.

signal(Name) ->
  Name ! {signal, self()},
  ok.

start_link(Name)  ->
  start_link(Name, []).

start_link(Name, DbgOpts)  ->
  proc_lib:start_link(?MODULE, init, [self(), Name, DbgOpts]).

stop(Name) -> Name ! stop.

init(Parent, Name, DbgOpts) ->
  register(Name, self()),
  process_flag(trap_exit, true),
  Debug = sys:debug_options(DbgOpts),
  proc_lib:init_ack({ok, self()}),
  free(Name, Parent, Debug).

free(Name, Parent, Debug) ->
  receive
    {wait, Pid} ->  %% The user requests.
      NewDebug = sys:handle_debug(Debug, fun debug/3, Name, {wait, Pid}),
      link(Pid),
      Pid ! {self(), ok},
      busy(Pid, Name, Parent, NewDebug);
    {system, From, Msg} -> %% The system message.
      sys:handle_system_msg(Msg, From, Parent, ?MODULE, Debug, {free, Name});
    stop ->
      terminate(stopped, Name);
    {'EXIT', Parent, Reason} ->
      terminate(Reason, Name)
  end.

busy(Pid, Name, Parent, Debug) ->
  receive
    {signal, Pid} ->
      NewDebug = sys:handle_debug(Debug, fun debug/3, Name, {signal, Pid}),
      free(Name, Parent, NewDebug);
    {system, From, Msg} -> %% The system message.
      sys:handle_system_msg(Msg, From, Parent, ?MODULE, Debug, {busy, Pid, Name});
    {'EXIT', Parent, Reason} ->
      exit(Pid, Reason),
      terminate(Reason, Name)
  end.

terminate(Reason, Name) ->
  unregister(Name),
  terminate(Reason).
terminate(Reason) ->
  receive
    {wait, Pid} ->
      exit(Pid, Reason),
      terminate(reason)
    after 0 ->
      exit(Reason)
  end.

debug(Dev, Event, Name) ->
  io:format(Dev, "mutex ~w: ~w~n", [Name, Event]).

system_continue(Parent, Debug, {busy, Pid, Name}) ->
  busy(Pid, Name, Parent, Debug);
system_continue(Parent, Debug, {free, Name}) ->
  free(Name, Parent, Debug).

system_terminate(Reason, _Parent, _Debug, {busy, Pid, Name}) ->
  exit(Pid, reason),
  terminate(Reason, Name);
system_terminate(Reason, _Parent, _Debug, {free, Name}) ->
  terminate(Reason, Name).
