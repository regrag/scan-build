# RUN: mkdir %T/exit_code_for_success
# RUN: cd %T/exit_code_for_success; %{scan-build} true
# RUN: cd %T/exit_code_for_success; %{scan-build} --status-bugs true
# RUN: cd %T/exit_code_for_success; %{scan-build} --status-bugs false
# RUN: cd %T/exit_code_for_success; %{scan-build} --status-bugs --plist true
# RUN: cd %T/exit_code_for_success; %{scan-build} --status-bugs --plist false
