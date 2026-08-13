#!/bin/bash

set -eux

cargo b -r -p collector --bin rustc-fake
cargo b -r -p collector
cargo b -r

if cd rust-clippy; then git pull; else git clone https://github.com/rust-lang/rust-clippy && cd rust-clippy; fi

cargo build --profile clippy-build
export LD_LIBRARY_PATH="$(rustc --print=sysroot)/lib"
cd ../../../ # Back to project root

# EXTRA_ARGS="--exact-match cranelift-codegen-0.119.0"

cargo r --bin collector -r profile_local callgrind +nightly-$(date '+%Y-%m-%d') --profiles Clippy,Check --clippy site/frontend/rust-clippy/target/clippy-build/clippy-driver $EXTRA_ARGS
cargo r --bin collector -r bench_local +nightly-$(date '+%Y-%m-%d') --profiles Clippy,Check --clippy site/frontend/rust-clippy/target/clippy-build/clippy-driver $EXTRA_ARGS
# cargo r --bin collector -r profile_local callgrind +nightly-$1 --profiles Clippy,Check --clippy site/frontend/rust-clippy/target/clippy-build/clippy-driver $EXTRA_ARGS
# cargo r --bin collector -r bench_local +nightly-$1 --profiles Clippy,Check --clippy site/frontend/rust-clippy/target/clippy-build/clippy-driver $EXTRA_ARGS
exit 0