dialyzer_dirs = lexical_shared lexical_plugin

compile.all: compile.umbrella

dialyzer.all: compile.all dialyzer.umbrella

test.all: test.umbrella

dialyzer.plt.all: dialyzer.plt.umbrella

dialyzer.umbrella:
	mix dialyzer

dialyzer.plt.umbrella:
	mix dialyzer --plt

test.umbrella:
	mix test

compile.umbrella:
	mix deps.get
	mix compile --skip-umbrella-children --warnings-as-errors


