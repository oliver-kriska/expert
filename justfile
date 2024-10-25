deps project:
  #!/usr/bin/env bash
  cd {{project}}
  mix deps.get

run project +ARGS:
  #!/usr/bin/env bash
  set -euo pipefail
  cd {{project}}
  eval "{{ ARGS }}"


compile project:
  #!/usr/bin/env bash
  set -euo pipefail

  cd {{project}}
  mix_env="${MIX_ENV:-dev}"
  build_dir="_build/$mix_env"
  safe_dir="_build/$mix_env-safe"
  # create our safekeeping area
  mkdir -p "$safe_dir"
  # delete what is currently in the build dir
  rm -rf "$build_dir"
  # move our build artifacts from safekeeping to the build area
  cp -a "$safe_dir/." "$build_dir/"
  # compile the safe kept code, respects incremental compilation
  mix compile
  # prep the safe area for new code
  rm -rf "$safe_dir/"
  # copy new code in the safe area
  cp -a "$build_dir/." "$safe_dir/"

build project *args: (compile project)
  #!/usr/bin/env bash
  set -euo pipefail
  mix_env="${MIX_ENV:-dev}"
  build_dir="_build/$mix_env"

  cd {{project}}

  # namespace the new code
  mix namespace --directory "$build_dir" {{args}}

start *opts="--port 9000": \
  (build "engine" "--include-app engine --include-root Engine --exclude-app namespace --apps") \
  (build "expert" "--include-app expert --exclude-root Expert --exclude-app burrito --exclude-app namespace --exclude-root Jason --include-root Engine")
  #!/usr/bin/env bash
  cd expert

  # no compile is important so it doesn't mess up the namespacing
  EXPERT_ENGINE_PATH="../engine/_build/${MIX_ENV:-dev}/" mix run \
      --no-compile \
      --no-halt \
      -e "Application.ensure_all_started(:expert)" \
      -- {{opts}}

test project:
  #!/usr/bin/env bash
  cd {{project}}
  mix test

format project:
  #!/usr/bin/env bash
  cd {{project}}
  mix format

[unix]
release-local: \
  (build "engine" "--include-app engine --include-root Engine --exclude-app namespace --apps") \
  (build "expert" "--include-app expert --exclude-root Expert --exclude-app burrito --exclude-app namespace --exclude-root Jason --include-root Engine")
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

  EXPERT_RELEASE_MODE=burrito BURRITO_TARGET="$target" MIX_ENV=prod mix release --no-compile

[windows]
release-local:
  # idk actually how to set env vars like this on windows, might crash
  EXPERT_RELEASE_MODE=burrito BURRITO_TARGET="windows_amd64" MIX_ENV=prod mix release

release-all:
  cd expert
  EXPERT_RELEASE_MODE=burrito MIX_ENV=prod mix release

release-plain:
  cd expert
  MIX_ENV=prod mix release plain
