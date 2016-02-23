-module (record).
-compile (export_all).

-record(robot, {name,
                type=industrial,
                hobbies,
                details=[]}).

first_robot() ->
  #robot{name="Machatron",
         type=handmade,
         details=["Moved by a small man insides"]}.
