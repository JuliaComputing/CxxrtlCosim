# prologue.jl
using Yosys_jll
using Clang_jll
using Libdl
libcxxrtl = missing;

inc = joinpath(Yosys_jll.find_artifact_dir(), "share/yosys/include")
capi = joinpath(inc, "backends/cxxrtl/cxxrtl_capi.cc")
# end