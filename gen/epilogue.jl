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

function synth(output, files...)
    cmd = Yosys_jll.yosys()
    push!(cmd.exec, "-p", "write_cxxrtl $(output)", files...)
    run(cmd)
end

function compile(output, mod)
    cmd = Clang_jll.clang()
    push!(cmd.exec, "-g", "-O3", "-fPIC", "-shared", "-std=c++14",
                    "-I$(inc)", capi, mod, "-o", output)
    run(cmd)
end

function load(lib)
    global libcxxrtl = lib
    ccall((:cxxrtl_design_create, libcxxrtl), cxxrtl_toplevel, ())
end
# end