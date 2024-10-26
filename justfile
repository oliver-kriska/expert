mix_env := env('MIX_ENV', 'dev')
build_dir := "_build" / mix_env
safe_dir := "_build" / mix_env + "safe"
os := if os() == "macos" { "darwin" } else { os() }
arch := if arch() =~ "(arm|aarch64)" {
  "arm64"
} else if arch() =~ "(x86|x86_64)" {
  "amd64"
} else {
  "unsupported"
}
local_target := if os =~ "(darwin|linux|windows)" {
  os + "_" + arch
} else {
  "unsupported"
}

apps := "expert engine namespace"

deps project:
  #!/usr/bin/env bash
  cd {{project}}
  mix deps.get

run project +ARGS:
  #!/usr/bin/env bash
  set -euo pipefail
  cd {{project}}
  eval "{{ ARGS }}"

compile project: (deps project)
  #!/usr/bin/env bash
  set -euo pipefail

  cd {{project}}
  # create our safekeeping area
  mkdir -p {{safe_dir}}
  # delete what is currently in the build dir
  rm -rf {{ build_dir }} 
  # move our build artifacts from safekeeping to the build area
  cp -a "{{ safe_dir }}/." "{{ build_dir }}/"
  # compile the safe kept code, respects incremental compilation
  mix compile
  # prep the safe area for new code
  rm -rf "{{ safe_dir }}/"
  # copy new code in the safe area
  cp -a "{{ build_dir }}/." "{{ safe_dir }}/"

build project *args: (compile project)
  #!/usr/bin/env bash
  set -euo pipefail

  cd {{project}}

  # namespace the new code
  mix namespace --directory "{{ build_dir }}" {{args}}

build-engine: (build "engine" "--include-app engine --include-root Engine --exclude-app namespace --dot-apps")
build-expert: (build "expert" "--include-app expert --exclude-root Expert --exclude-app burrito --exclude-app req --exclude-app finch --exclude-app nimble_options --exclude-app nimble_pool --exclude-app namespace --exclude-root Jason --include-root Engine")

start *opts="--port 9000": build-engine build-expert
  #!/usr/bin/env bash
  cd expert

  # no compile is important so it doesn't mess up the namespacing
  EXPERT_ENGINE_PATH="../engine/_build/{{ mix_env }}/" mix run \
      --no-compile \
      --no-halt \
      -e "Application.ensure_all_started(:expert)" \
      -- {{opts}}

mix cmd *project: 
  #!/usr/bin/env bash

  if [ -n "{{ project }}" ]; then
    cd {{project}}
    mix {{cmd}}
  else
    for project in {{ apps }}; do
    (
      cd "$project"

      mix {{ cmd }}
    )
    done
  fi

[unix]
release-local: build-engine build-expert
  #!/usr/bin/env bash
  cd expert

  if [ "{{local_target}}" == "unsupported" ]; then
    echo "unsupported OS/Arch combination: {{local_target}}"
    exit 1
  fi
  EXPERT_RELEASE_MODE=burrito BURRITO_TARGET="{{local_target}}" MIX_ENV=prod mix release --no-compile

[windows]
release-local: build-engine build-expert
  # idk actually how to set env vars like this on windows, might crash
  EXPERT_RELEASE_MODE=burrito BURRITO_TARGET="windows_amd64" MIX_ENV=prod mix release --no-compile

release-all: build-engine build-expert
  #!/usr/bin/env bash
  cd expert
  EXPERT_RELEASE_MODE=burrito MIX_ENV=prod mix release --no-compile

release-plain: build-engine build-expert
  #!/usr/bin/env bash
  cd expert
  MIX_ENV=prod mix release plain --no-compile
