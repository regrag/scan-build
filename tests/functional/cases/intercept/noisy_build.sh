#!/usr/bin/env bash

# RUN: bash %s %T/noisy_build
# RUN: cd %T/noisy_build; %{intercept-build} --cdb wrapper.json --override-compiler ./run.sh
# RUN: cd %T/noisy_build; cdb_diff wrapper.json expected.json
#
# when library preload disabled, it falls back to use compiler wrapper
#
# RUN: cd %T/noisy_build; %{intercept-build} --cdb preload.json ./run.sh
# RUN: cd %T/noisy_build; cdb_diff preload.json expected.json

set -o errexit
set -o nounset
set -o xtrace

# the test creates a subdirectory inside output dir.
#
# ${root_dir}
# ├── run.sh
# ├── expected.json
# └── src
#    └── empty.c

root_dir=$1
mkdir -p "${root_dir}/src"

touch "${root_dir}/src/empty.c"

build_file="${root_dir}/run.sh"
cat >> ${build_file} << EOF
#!/usr/bin/env bash

set -o nounset
set -o xtrace

echo "hi there \"people\""
echo "hi	again"

"\$CC" -c -o src/empty.o -Dver=1 src/empty.c;
"\$CXX" -c -o src/empty.o -Dver=2 src/empty.c;

bash -c "\
mkdir -p ./this/that \
touch ./this/that \
rm -rf ./this"

true;
EOF
chmod +x ${build_file}

cat >> "${root_dir}/expected.json" << EOF
[
{
  "command": "cc -c -o src/empty.o -Dver=1 src/empty.c",
  "directory": "${root_dir}",
  "file": "src/empty.c"
}
,
{
  "command": "c++ -c -o src/empty.o -Dver=2 src/empty.c",
  "directory": "${root_dir}",
  "file": "src/empty.c"
}
]
EOF
