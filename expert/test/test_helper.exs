Logger.configure(level: :warning)

ExUnit.start(assert_receive_timeout: 30_000)
