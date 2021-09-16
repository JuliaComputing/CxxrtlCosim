module CxxrtlCosim

# prologue.jl
using Yosys_jll
using Clang_jll
using Libdl
libcxxrtl = missing;

inc = joinpath(Yosys_jll.find_artifact_dir(), "share/yosys/include")
capi = joinpath(inc, "backends/cxxrtl/cxxrtl_capi.cc")
# end

mutable struct _cxxrtl_toplevel end

const cxxrtl_toplevel = Ptr{_cxxrtl_toplevel}

mutable struct _cxxrtl_handle end

const cxxrtl_handle = Ptr{_cxxrtl_handle}

function cxxrtl_create(design)
    ccall((:cxxrtl_create, libcxxrtl), cxxrtl_handle, (cxxrtl_toplevel,), design)
end

function cxxrtl_create_at(design, root)
    ccall((:cxxrtl_create_at, libcxxrtl), cxxrtl_handle, (cxxrtl_toplevel, Ptr{Cchar}), design, root)
end

function cxxrtl_destroy(handle)
    ccall((:cxxrtl_destroy, libcxxrtl), Cvoid, (cxxrtl_handle,), handle)
end

function cxxrtl_reset(handle)
    ccall((:cxxrtl_reset, libcxxrtl), Cvoid, (cxxrtl_handle,), handle)
end

function cxxrtl_eval(handle)
    ccall((:cxxrtl_eval, libcxxrtl), Cint, (cxxrtl_handle,), handle)
end

function cxxrtl_commit(handle)
    ccall((:cxxrtl_commit, libcxxrtl), Cint, (cxxrtl_handle,), handle)
end

function cxxrtl_step(handle)
    ccall((:cxxrtl_step, libcxxrtl), Csize_t, (cxxrtl_handle,), handle)
end

@enum cxxrtl_type::UInt32 begin
    CXXRTL_VALUE = 0
    CXXRTL_WIRE = 1
    CXXRTL_MEMORY = 2
    CXXRTL_ALIAS = 3
    CXXRTL_OUTLINE = 4
end

@enum cxxrtl_flag::UInt32 begin
    CXXRTL_INPUT = 1
    CXXRTL_OUTPUT = 2
    CXXRTL_INOUT = 3
    CXXRTL_DRIVEN_SYNC = 4
    CXXRTL_DRIVEN_COMB = 8
    CXXRTL_UNDRIVEN = 16
end

mutable struct _cxxrtl_outline end

struct cxxrtl_object
    type::UInt32
    flags::UInt32
    width::Csize_t
    lsb_at::Csize_t
    depth::Csize_t
    zero_at::Csize_t
    curr::Ptr{UInt32}
    next::Ptr{UInt32}
    outline::Ptr{_cxxrtl_outline}
end

function cxxrtl_get_parts(handle, name, parts)
    ccall((:cxxrtl_get_parts, libcxxrtl), Ptr{cxxrtl_object}, (cxxrtl_handle, Ptr{Cchar}, Ptr{Csize_t}), handle, name, parts)
end

function cxxrtl_enum(handle, data, callback)
    ccall((:cxxrtl_enum, libcxxrtl), Cvoid, (cxxrtl_handle, Ptr{Cvoid}, Ptr{Cvoid}), handle, data, callback)
end

const cxxrtl_outline = Ptr{_cxxrtl_outline}

function cxxrtl_outline_eval(outline)
    ccall((:cxxrtl_outline_eval, libcxxrtl), Cvoid, (cxxrtl_outline,), outline)
end

# epilogue.jl

function cxxrtl_get(handle, name)
    parts = Ref(Csize_t(0));
	object = cxxrtl_get_parts(handle, name, parts)
	@assert(object == C_NULL || parts[] == 1)
	if (object == C_NULL || parts[] == 1)
		return object
    end
	return C_NULL
end

function cxxrtl_design_create(lib)
    global libcxxrtl = lib
    ccall((:cxxrtl_design_create, libcxxrtl), cxxrtl_toplevel, ())
end

function synth(output, files...)
    cmd = Yosys_jll.yosys()
    push!(cmd.exec, "-q", "-p", "write_cxxrtl $(output)", files...)
    run(cmd)
end

function compile(output, mod)
    cmd = Clang_jll.clang()
    push!(cmd.exec, "-g", "-O3", "-fPIC", "-shared", "-std=c++14",
                    "-I$(inc)", capi, mod, "-o", output)
    run(cmd)
end

include("cosim.jl")
# end

# exports
const PREFIXES = ["cxxrtl_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
