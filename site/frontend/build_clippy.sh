#!/bin/bash
export LC_ALL=C.UTF-8
set -eux
. "$HOME/.cargo/env"

cargo b -r -p collector --bin rustc-fake
cargo b -r -p collector
cargo b -r

if cd rust-clippy; then git pull; else git clone https://github.com/rust-lang/rust-clippy && cd rust-clippy; fi

cargo build --profile clippy-build
export LD_LIBRARY_PATH="$(rustc --print=sysroot)/lib"
cd ../../../ # Back to project root

# These ones depend on libc, which we cannot compile for some reason
#EXTRA_ARGS="--exclude cargo-0.87.1,eza-0.21.2,html5ever-0.31.0,html5ever-0.31.0-new-solver,image-0.25.6,libc-0.2.172,nalgebra-0.33.0,projection-caching,ripgrep-14.1.1,ripgrep-14.1.1-nll,ripgrep-14.1.1-tiny"
EXTRA_ARGS=""
# cargo r --bin collector -r profile_local callgrind +nightly-2026-08-14 --profiles Clippy,Check --clippy site/frontend/rust-clippy/target/clippy-build/clippy-driver
# cargo r --bin collector -r bench_local +nightly-2026- --profiles Clippy,Check --clippy site/frontend/rust-clippy/target/clippy-build/clippy-driver

cargo r --bin collector -r profile_local callgrind +nightly-$(date --date="1 days ago" '+%Y-%m-%d') --profiles Clippy,Check --clippy site/frontend/rust-clippy/target/clippy-build/clippy-driver $EXTRA_ARGS
cargo r --bin collector -r bench_local +nightly-$(date --date="1 days ago" '+%Y-%m-%d') --profiles Clippy,Check --clippy site/frontend/rust-clippy/target/clippy-build/clippy-driver $EXTRA_ARGS
# cargo r --bin collector -r profile_local callgrind +nightly-$1 --profiles Clippy,Check --clippy site/frontend/rust-clippy/target/clippy-build/clippy-driver $EXTRA_ARGS
# cargo r --bin collector -r bench_local +nightly-$1 --profiles Clippy,Check --clippy site/frontend/rust-clippy/target/clippy-build/clippy-driver $EXTRA_ARGS

cd ~/rustc-perf/
rsync --password-file=/home/CuiESgqXgcW2CX9LiyDB/cdn-pass.txt -av results* cdn@192.168.1.153::CDN/

exit 0
