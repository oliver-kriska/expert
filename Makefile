poncho_dirs = common lexical_credo proto protocol remote_control server

dialyzer_dirs = lexical_shared lexical_plugin

compile.all: compile.poncho

dialyzer.all: compile.poncho dialyzer.poncho

test.all: test.poncho

dialyzer.plt.all: dialyzer.plt.umbrella

dialyzer.umbrella:
	mix dialyzer

deps.poncho:
	$(foreach dir, $(poncho_dirs), cd apps/$(dir) && mix deps.get && cd ../..;)

dialyzer.plt.poncho:
	$(foreach dir, $(poncho_dirs), cd apps/$(dir) && mix dialyzer --plt && cd ../..;)

compile.poncho: deps.poncho
	$(foreach dir, $(poncho_dirs), cd apps/$(dir) && mix deps.get && mix compile --warnings-as-errors && cd ../..;)

test.poncho: deps.poncho
	$(foreach dir, $(poncho_dirs), cd apps/$(dir) && MIX_ENV=test mix test && cd ../..;)

dialyzer.poncho:
	$(foreach dir, $(poncho_dirs), cd apps/$(dir) && mix dialyzer && cd ../..;)
