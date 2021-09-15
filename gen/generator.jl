using Clang.Generators
using Yosys_jll

hapi = 

cd(@__DIR__)

include_dir = joinpath(Yosys_jll.find_artifact_dir(), "share/yosys/include") |> normpath

options = load_options(joinpath(@__DIR__, "generator.toml"))

# add compiler flags, e.g. "-DXXXXXXXXX"
args = get_default_args()
push!(args, "-I$include_dir")

headers = [joinpath(include_dir, "backends/cxxrtl/cxxrtl_capi.h")]

# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx)