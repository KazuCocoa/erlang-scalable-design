-module (bsc).
-behaviour (application).
-behaviour (supervisor).

-export ([start/2, stop/1, init/1]).

start(_StartType, _StartArgs) ->
  {ok, Pid} = supervisor:start_link({local, ?MODULE}, ?MODULE, []).

stop(_Data) ->
  ok.


init(_) ->
  ChildSpecList = [child(freq_overload), child(frequency)],
  {ok, {{rest_for_one, 2, 3600}, ChildSpecList}}.

child(Module) ->
  {Module, {Module, start_link, []}, permanent, 2000, worker, [Module]}.
