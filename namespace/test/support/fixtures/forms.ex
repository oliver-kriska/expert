defmodule Namespace.AbstractTest.Code do
  @compile {:no_warn_undefined, :baz}
  @compile {:no_warn_undefined, Bar.Foo}
  @compile {:no_warn_undefined, Engine}
  @compile {:no_warn_undefined, Foo}
  def run do
    another()
    Engine.thing()
  end

  defp another() do
    for _ <- Foo.boo() do
      :baz.run()
      Bar.Foo.run(:baz)
    end
  end
end

defmodule SomeApp do
  @compile {:no_warn_undefined, :baz}
  @compile {:no_warn_undefined, Bar.Foo}
  @compile {:no_warn_undefined, Engine}
  @compile {:no_warn_undefined, Foo}
  def run do
    another()
    Engine.thing()
  end

  defp another() do
    for _ <- Foo.boo() do
      :baz.run()
      Bar.Foo.run(:baz)
    end
  end
end
