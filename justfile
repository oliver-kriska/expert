mix_env := env('MIX_ENV', 'dev')
build_dir := "_build" / mix_env
namespaced_dir := "_build" / mix_env + "_ns"
os := if os() == "macos" { "darwin" } else { os() }
arch := if arch() =~ "(arm|aarch64)" { "arm64" } else { if arch() =~ "(x86|x86_64)" { "amd64" } else { "unsupported" } }
local_target := if os =~ "(darwin|linux|windows)" { os + "_" + arch } else { "unsupported" }
apps := "expert engine namespace"

[doc('Run mix deps.get for the given project')]
deps project:
    #!/usr/bin/env bash
    cd {{ project }}
    mix deps.get

[doc('Run an arbitrary command inside the given project directory')]
run project +ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    cd {{ project }}
    eval "{{ ARGS }}"

[doc('Compile the given project.')]
compile project: (deps project)
  cd {{ project }} && mix compile

[private]
build project *args: (compile project)
    #!/usr/bin/env bash
    set -euo pipefail

    cd {{ project }}

    # remove the existing namespaced dir
    rm -rf {{ namespaced_dir }} 
    # create our namespaced area
    mkdir -p {{ namespaced_dir }}
    # move our build artifacts from safekeeping to the build area
    cp -a "{{ build_dir }}/." "{{ namespaced_dir }}/"

    # namespace the new code
    mix namespace --directory "{{ namespaced_dir }}" {{ args }}

[private]
build-engine: (build "engine" "--include-app engine --include-root Engine --dot-apps")

[private]
build-expert: (build "expert" "--include-app expert --exclude-root Expert --exclude-app burrito --exclude-app req --exclude-app finch --exclude-app nimble_options --exclude-app nimble_pool --exclude-app namespace --exclude-root Jason --include-root Engine --include-app engine")

[doc('Run tests in the given project')]
test project="all" *args="": 
    MIX_ENV=test just _test {{ project }} {{ args }}

[private]
_test project="all" *args="":
    #!/usr/bin/env bash
    set -euo pipefail

    case "{{ project }}" in
      expert)
        cd {{ project }}
        # compile in dev env to simulate normal conditions
        # note that we aren't namespacing during the tests
        # lexical doesn't seem to namespace as far as I can tell, and
        # figuring out how to namespace the test files seemed like a rabbit hole
        MIX_ENV=dev just compile engine
        export EXPERT_ENGINE_PATH="../engine/_build/dev"
        mix compile
        mix test --no-compile {{ args }}
        ;;
      all)
        for project in {{ apps }}; do
          echo "Testing $project"
          just _test "$project"
        done
        ;;
      *)
        cd {{ project }}
        mix compile
        mix test --no-compile {{ args }}
        ;;
    esac

[doc('Start the local development server')]
start *opts="--port 9000": build-engine build-expert
    #!/usr/bin/env bash
    set -euo pipefail
    cd expert

    # no compile is important so it doesn't mess up the namespacing
    # we set the MIX_BUILD_PATH because we put the namespaced code into a separate directory
    MIX_BUILD_PATH="{{ namespaced_dir }}" EXPERT_ENGINE_PATH="{{ "../engine" / namespaced_dir }}" mix run \
        --no-compile \
        --no-halt \
        -e "Application.ensure_all_started(:expert)" \
        -- {{ opts }}


[doc('Run a mix command in one or all projects. Use `just test` to run tests.')]
mix cmd *project:
    #!/usr/bin/env bash

    if [ -n "{{ project }}" ]; then
      cd {{ project }}
      mix {{ cmd }}
    else
      for project in {{ apps }}; do
      (
        cd "$project"

        mix {{ cmd }}
      )
      done
    fi

[doc('Build a release for the local system')]
[unix]
release-local: build-engine build-expert
    #!/usr/bin/env bash
    cd expert

    if [ "{{ local_target }}" == "unsupported" ]; then
      echo "unsupported OS/Arch combination: {{ local_target }}"
      exit 1
    fi
    EXPERT_RELEASE_MODE=burrito BURRITO_TARGET="{{ local_target }}" mix release --no-compile

[windows]
release-local: build-engine build-expert
    # idk actually how to set env vars like this on windows, might crash
    EXPERT_RELEASE_MODE=burrito BURRITO_TARGET="windows_amd64" MIX_ENV=prod mix release --no-compile

[doc('Build releases for all target platforms')]
release-all: build-engine build-expert
    #!/usr/bin/env bash
    cd expert
    EXPERT_RELEASE_MODE=burrito MIX_ENV=prod mix release --no-compile

[doc('Build a plain release without burrito')]
release-plain: build-engine build-expert
    #!/usr/bin/env bash
    cd expert
    MIX_ENV=prod mix release plain --no-compile
