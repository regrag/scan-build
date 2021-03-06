#!/usr/bin/env bash

# RUN: bash %s %T/output_dir_kept
# RUN: cd %T/output_dir_kept; %{scan-build} --output . ./run.sh | ./check.sh
# RUN: cd %T/output_dir_kept; %{scan-build} --output . --plist ./run.sh | ./check.sh

set -o errexit
set -o nounset
set -o xtrace

# the test creates a subdirectory inside output dir.
#
# ${root_dir}
# ├── run.sh
# ├── check.sh
# └── src
#    └── broken.c

root_dir=$1
mkdir -p "${root_dir}/src"

cp "${test_input_dir}/div_zero.c" "${root_dir}/src/broken.c"

build_file="${root_dir}/run.sh"
cat >> "${build_file}" << EOF
#!/usr/bin/env bash

set -o nounset
set -o xtrace

\${CC} -c -o src/broken.o src/broken.c
true
EOF
chmod +x "${build_file}"

checker_file="${root_dir}/check.sh"
cat >> "${checker_file}" << EOF
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o xtrace

out_dir=\$(sed -n 's/\(.*\) Report directory created: \(.*\)/\2/p')
if [ ! -d "\$out_dir" ]
then
    echo "output directory should exists"
    false
fi
EOF
chmod +x "${checker_file}"
