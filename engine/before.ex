[
  {:attribute, 1, :file, {~c"lib/schematic/unification.ex", 1}},
  {:attribute, 1, :module, Schematic.Unification},
  {:attribute, 1, :compile,
   [:no_auto_import, :debug_info, {:inline, [struct_impl_for: 1]}]},
  {:attribute, 4, :callback,
   {{:unify, 3},
    [
      {:type, 4, :fun,
       [
         {:type, 4, :product,
          [
            {:user_type, 4, :t, []},
            {:type, 4, :term, []},
            {:type, 4, :term, []}
          ]},
         {:type, 4, :term, []}
       ]}
    ]}},
  {:attribute, 5, :callback,
   {{:message, 1},
    [
      {:type, 5, :fun,
       [{:type, 5, :product, [{:user_type, 5, :t, []}]}, {:type, 5, :term, []}]}
    ]}},
  {:attribute, 6, :callback,
   {{:kind, 1},
    [
      {:type, 6, :fun,
       [{:type, 6, :product, [{:user_type, 6, :t, []}]}, {:type, 6, :term, []}]}
    ]}},
  {:attribute, 1, :spec,
   {{:impl_for!, 1},
    [
      {:type, 1, :fun,
       [{:type, 1, :product, [{:type, 1, :term, []}]}, {:type, 1, :atom, []}]}
    ]}},
  {:attribute, 1, :spec,
   {{:impl_for, 1},
    [
      {:type, 1, :fun,
       [
         {:type, 1, :product, [{:type, 1, :term, []}]},
         {:type, 1, :union, [{:type, 1, :atom, []}, {:atom, 0, nil}]}
       ]}
    ]}},
  {:attribute, 1, :spec,
   {{:__protocol__, 1},
    [
      {:type, 1, :fun,
       [
         {:type, 1, :product, [{:atom, 0, :module}]},
         {:atom, 0, Schematic.Unification}
       ]},
      {:type, 1, :fun,
       [
         {:type, 1, :product, [{:atom, 0, :functions}]},
         {:type, 0, :nonempty_list,
          [
            {:type, 0, :union,
             [
               {:type, 0, :tuple, [{:atom, 0, :unify}, {:integer, 0, 3}]},
               {:type, 0, :tuple, [{:atom, 0, :message}, {:integer, 0, 1}]},
               {:type, 0, :tuple, [{:atom, 0, :kind}, {:integer, 0, 1}]}
             ]}
          ]}
       ]},
      {:type, 1, :fun,
       [
         {:type, 1, :product, [{:atom, 0, :consolidated?}]},
         {:type, 1, :boolean, []}
       ]},
      {:type, 1, :fun,
       [
         {:type, 1, :product, [{:atom, 0, :impls}]},
         {:type, 1, :union,
          [
            {:atom, 0, :not_consolidated},
            {:type, 0, :tuple,
             [
               {:atom, 0, :consolidated},
               {:type, 0, :list, [{:type, 1, :module, []}]}
             ]}
          ]}
       ]}
    ]}},
  {:attribute, 1, :export_type, [t: 0]},
  {:attribute, 1, :type, {:t, {:type, 1, :term, []}, []}},
  {:attribute, 1, :dialyzer,
   {:nowarn_function, [__protocol__: 1, impl_for: 1, impl_for!: 1]}},
  {:attribute, 1, :__protocol__, [fallback_to_any: true]},
  {:attribute, 1, :export,
   [
     __info__: 1,
     __protocol__: 1,
     impl_for: 1,
     impl_for!: 1,
     kind: 1,
     message: 1,
     unify: 3
   ]},
  {:attribute, 1, :spec,
   {{:__info__, 1},
    [
      {:type, 1, :fun,
       [
         {:type, 1, :product,
          [
            {:type, 1, :union,
             [
               {:atom, 1, :attributes},
               {:atom, 1, :compile},
               {:atom, 1, :functions},
               {:atom, 1, :macros},
               {:atom, 1, :md5},
               {:atom, 1, :exports_md5},
               {:atom, 1, :module},
               {:atom, 1, :deprecated},
               {:atom, 1, :struct}
             ]}
          ]},
         {:type, 1, :any, []}
       ]}
    ]}},
  {:function, 0, :__info__, 1,
   [
     {:clause, 0, [{:atom, 0, :module}], [],
      [{:atom, 0, Schematic.Unification}]},
     {:clause, 0, [{:atom, 0, :functions}], [],
      [
        {:cons, 0, {:tuple, 0, [{:atom, 0, :__protocol__}, {:integer, 0, 1}]},
         {:cons, 0, {:tuple, 0, [{:atom, 0, :impl_for}, {:integer, 0, 1}]},
          {:cons, 0, {:tuple, 0, [{:atom, 0, :impl_for!}, {:integer, 0, 1}]},
           {:cons, 0, {:tuple, 0, [{:atom, 0, :kind}, {:integer, 0, 1}]},
            {:cons, 0, {:tuple, 0, [{:atom, 0, :message}, {:integer, 0, 1}]},
             {:cons, 0, {:tuple, 0, [{:atom, 0, :unify}, {:integer, 0, 3}]},
              {nil, 0}}}}}}}
      ]},
     {:clause, 0, [{:atom, 0, :macros}], [], [nil: 0]},
     {:clause, 0, [{:atom, 0, :struct}], [], [{:atom, 0, nil}]},
     {:clause, 0, [{:atom, 0, :exports_md5}], [],
      [
        {:bin, 0,
         [
           {:bin_element, 0,
            {:string, 0,
             [89, 58, 13, 228, 237, 62, 86, 234, 224, 87, 49, 205, 30, 99, 0,
              126]}, :default, :default}
         ]}
      ]},
     {:clause, 0, [{:match, 0, {:var, 0, :Key}, {:atom, 0, :attributes}}], [],
      [
        {:call, 0,
         {:remote, 0, {:atom, 0, :erlang}, {:atom, 0, :get_module_info}},
         [{:atom, 0, Schematic.Unification}, {:var, 0, :Key}]}
      ]},
     {:clause, 0, [{:match, 0, {:var, 0, :Key}, {:atom, 0, :compile}}], [],
      [
        {:call, 0,
         {:remote, 0, {:atom, 0, :erlang}, {:atom, 0, :get_module_info}},
         [{:atom, 0, Schematic.Unification}, {:var, 0, :Key}]}
      ]},
     {:clause, 0, [{:match, 0, {:var, 0, :Key}, {:atom, 0, :md5}}], [],
      [
        {:call, 0,
         {:remote, 0, {:atom, 0, :erlang}, {:atom, 0, :get_module_info}},
         [{:atom, 0, Schematic.Unification}, {:var, 0, :Key}]}
      ]},
     {:clause, 0, [{:atom, 0, :deprecated}], [], [nil: 0]}
   ]},
  {:function, 1, :impl_for!, 1,
   [
     {:clause, [generated: true, location: 0], [{:var, 1, :_@1}], [],
      [{:call, 1, {:atom, 1, :impl_for}, [{:var, 1, :_@1}]}]}
   ]},
  {:function, 6, :kind, 1,
   [
     {:clause, 6, [{:var, 6, :_@1}], [],
      [
        {:call, 6,
         {:remote, 6, {:call, 6, {:atom, 6, :impl_for!}, [{:var, 6, :_@1}]},
          {:atom, 6, :kind}}, [{:var, 6, :_@1}]}
      ]}
   ]},
  {:function, 5, :message, 1,
   [
     {:clause, 5, [{:var, 5, :_@1}], [],
      [
        {:call, 5,
         {:remote, 5, {:call, 5, {:atom, 5, :impl_for!}, [{:var, 5, :_@1}]},
          {:atom, 5, :message}}, [{:var, 5, :_@1}]}
      ]}
   ]},
  {:function, 4, :unify, 3,
   [
     {:clause, 4, [{:var, 4, :_@1}, {:var, 4, :_@2}, {:var, 4, :_@3}], [],
      [
        {:call, 4,
         {:remote, 4, {:call, 4, {:atom, 4, :impl_for!}, [{:var, 4, :_@1}]},
          {:atom, 4, :unify}},
         [{:var, 4, :_@1}, {:var, 4, :_@2}, {:var, 4, :_@3}]}
      ]}
   ]},
  {:function, 1, :struct_impl_for, 1,
   [
     {:clause, [generated: true, location: 0],
      [{:atom, [generated: true, location: 0], Schematic}], [],
      [{:atom, [generated: true, location: 0], Schematic.Unification.Schematic}]},
     {:clause, [generated: true, location: 0], [{:var, 0, :_}], [],
      [{:atom, [generated: true, location: 0], Schematic.Unification.Any}]}
   ]},
  {:function, 1, :impl_for, 1,
   [
     {:clause, [generated: true, location: 0],
      [
        {:map, 1,
         [{:map_field_exact, 1, {:atom, 1, :__struct__}, {:var, 1, :_@1}}]}
      ],
      [
        [
          {:call, 1, {:remote, 1, {:atom, 1, :erlang}, {:atom, 1, :is_atom}},
           [{:var, 1, :_@1}]}
        ]
      ], [{:call, 1, {:atom, 1, :struct_impl_for}, [{:var, 1, :_@1}]}]},
     {:clause, [generated: true, location: 0], [{:var, 0, :_}], [],
      [{:atom, [generated: true, location: 0], Schematic.Unification.Any}]}
   ]},
  {:function, 1, :__protocol__, 1,
   [
     {:clause, [generated: true, location: 0],
      [{:atom, [generated: true, location: 0], :module}], [],
      [{:atom, [generated: true, location: 0], Schematic.Unification}]},
     {:clause, [generated: true, location: 0],
      [{:atom, [generated: true, location: 0], :functions}], [],
      [
        {:cons, [generated: true, location: 0],
         {:tuple, [generated: true, location: 0],
          [
            {:atom, [generated: true, location: 0], :kind},
            {:integer, [generated: true, location: 0], 1}
          ]},
         {:cons, [generated: true, location: 0],
          {:tuple, [generated: true, location: 0],
           [
             {:atom, [generated: true, location: 0], :message},
             {:integer, [generated: true, location: 0], 1}
           ]},
          {:cons, [generated: true, location: 0],
           {:tuple, [generated: true, location: 0],
            [
              {:atom, [generated: true, location: 0], :unify},
              {:integer, [generated: true, location: 0], 3}
            ]}, {nil, [generated: true, location: 0]}}}}
      ]},
     {:clause, [generated: true, location: 0],
      [{:atom, [generated: true, location: 0], :consolidated?}], [],
      [{:atom, [generated: true, location: 0], true}]},
     {:clause, [generated: true, location: 0],
      [{:atom, [generated: true, location: 0], :impls}], [],
      [
        {:tuple, [generated: true, location: 0],
         [
           {:atom, [generated: true, location: 0], :consolidated},
           {:cons, [generated: true, location: 0],
            {:atom, [generated: true, location: 0], Any},
            {:cons, [generated: true, location: 0],
             {:atom, [generated: true, location: 0], Schematic},
             {nil, [generated: true, location: 0]}}}
         ]}
      ]}
   ]}
]