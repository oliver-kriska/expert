defmodule Expert.Release do
  def assemble(release) do
    engine_path = Path.expand("../../../engine", __DIR__)

    {_, 0} =
      System.cmd("mix", ["build"],
        cd: engine_path,
        env: [
          {"MIX_ENV", to_string(Mix.env())}
        ]
      )

    {_, 0} =
      System.cmd("mix", ["namespace"],
        env: [
          {"MIX_ENV", to_string(Mix.env())}
        ]
      )

    source = Path.join([engine_path, "_build/#{Mix.env()}"])

    dest =
      Path.join([
        release.path,
        "lib",
        "#{release.name}-#{release.version}",
        "priv"
      ])

    File.cp_r!(source, dest)

    release
  end
end
