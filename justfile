deps project:
  #!/usr/bin/env bash
  cd {{project}}
  mix deps.get

compile project:
  #!/usr/bin/env bash
  cd {{project}}
  mix compile

build:
  #!/usr/bin/env bash
  cd engine
  mix build

start:
  #!/usr/bin/env bash
  cd expert
  bin/start --port 9000

test project:
  #!/usr/bin/env bash
  cd {{project}}
  mix test

format project:
  #!/usr/bin/env bash
  cd {{project}}
  mix format

[unix]
build-local:
  #!/usr/bin/env bash
  cd expert
  case "{{os()}}-{{arch()}}" in
    "linux-arm" | "linux-aarch64")
      target=linux_arm64;;
    "linux-x86" | "linux-x86_64")
      target=linux_amd64;;
    "macos-arm" | "macos-aarch64")
      target=darwin_arm64;;
    "macos-x86" | "macos-x86_64")
      target=darwin_amd64;;
    *)
      echo "unsupported OS/Arch combination"
      exit 1;;
  esac

  EXPERT_RELEASE_MODE=burrito BURRITO_TARGET="$target" MIX_ENV=prod mix release

[windows]
build-local:
  # idk actually how to set env vars like this on windows, might crash
  EXPERT_RELEASE_MODE=burrito BURRITO_TARGET="windows_amd64" MIX_ENV=prod mix release

build-all:
  cd expert
  EXPERT_RELEASE_MODE=burrito MIX_ENV=prod mix release

build-plain:
  cd expert
  MIX_ENV=prod mix release plain
