#!/bin/bash

set -eux

cargo b -r -p collector --bin rustc-fake
cargo b -r -p collector
cargo b -r

if cd rust-clippy; then git pull; else git clone https://github.com/rust-lang/rust-clippy && cd rust-clippy; fi

cargo build --profile clippy-build
export LD_LIBRARY_PATH="$(rustc --print=sysroot)/lib"
cd ../../../ # Back to project root

# These ones depend on libc, which we cannot compile for some reason
EXTRA_ARGS="--exclude cargo-0.87.1 \
--exclude eza-0.21.2 \
--exclude html5ever-0.31.0 \
--exclude html5ever-0.31.0-new-solver \
--exclude image-0.25.6 \
--exclude libc-0.2.172 \
--exclude nalgebra-0.33.0 \
--exclude nalgebra-0.33.0-new-solver \
--exclude projection-caching \
--exclude ripgrep-14.1.1 \
--exclude ripgrep-14.1.1-nll \
--exclude ripgrep-14.1.1-tiny"

# cargo r --bin collector -r profile_local callgrind +nightly-2026-08-14 --profiles Clippy,Check --clippy site/frontend/rust-clippy/target/clippy-build/clippy-driver
# cargo r --bin collector -r bench_local +nightly-2026- --profiles Clippy,Check --clippy site/frontend/rust-clippy/target/clippy-build/clippy-driver

cargo r --bin collector -r profile_local callgrind +nightly-$(date '+%Y-%m-%d') --profiles Clippy,Check --clippy site/frontend/rust-clippy/target/clippy-build/clippy-driver
cargo r --bin collector -r bench_local +nightly-$(date '+%Y-%m-%d') --profiles Clippy,Check --clippy site/frontend/rust-clippy/target/clippy-build/clippy-driver
# cargo r --bin collector -r profile_local callgrind +nightly-$1 --profiles Clippy,Check --clippy site/frontend/rust-clippy/target/clippy-build/clippy-driver $EXTRA_ARGS
# cargo r --bin collector -r bench_local +nightly-$1 --profiles Clippy,Check --clippy site/frontend/rust-clippy/target/clippy-build/clippy-driver $EXTRA_ARGS
exit 0
