poncho_dirs = common lexical_credo proto protocol remote_control server

dialyzer_dirs= lexical_shared lexical_plugin

compile.all: compile.poncho

dialyzer.all: compile.poncho dialyzer.poncho

test.all: test.poncho

dialyzer.plt.all: dialyzer.plt.poncho

deps.poncho:
	$(foreach dir, $(poncho_dirs), cd apps/$(dir) && mix deps.get && cd ../..;)

deps.compile.poncho: deps.poncho
	$(foreach dir, $(poncho_dirs), cd apps/$(dir) && mix deps.compile && cd ../..;)

compile.poncho: deps.poncho
	$(foreach dir, $(poncho_dirs), cd apps/$(dir) && mix deps.get && mix compile --warnings-as-errors && cd ../..;)

compile.protocols.poncho: deps.poncho
	$(foreach dir, $(poncho_dirs), cd apps/$(dir) && mix deps.get && mix compile.protocols --warnings-as-errors && cd ../..;)

test.poncho: deps.poncho
	$(foreach dir, $(poncho_dirs), cd apps/$(dir) && MIX_ENV=test mix test && cd ../..;)

format.check.poncho: deps.poncho
	$(foreach dir, $(poncho_dirs), cd apps/$(dir) && mix format --check-formatted && cd ../..;)

credo.check.poncho: deps.poncho
	$(foreach dir, $(poncho_dirs), cd apps/$(dir) && mix credo && cd ../..;)

dialyzer.plt.poncho:
	$(foreach dir, $(poncho_dirs), cd apps/$(dir) && mix dialyzer --plt && cd ../..;)

dialyzer.poncho: compile.poncho compile.protocols.poncho
	$(foreach dir, $(poncho_dirs), cd apps/$(dir) && mix dialyzer && cd ../..;)
