{application, bsc,
 [{description, "Base Station Controller"},
  {vsn, "1.0"},
  {modules, [bsc, bsc_sup]},
  {registered, [bsc_sup]},
  {applications, [kernel, stdlib, sasl]},
  {env, []},
  {mod, {bsc,[]}}
 ]}.
