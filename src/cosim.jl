using ModelingToolkit

prevt = Ref(0)

function rtlget(t, handle::cxxrtl_handle, val::String)
    rtlref = CxxrtlCosim.cxxrtl_get(handle, val)
    pt = prevt[]
    if t != pt # do timestep
        prevt[] = t
        cxxrtl_step(handle)
    end
    unsafe_load(unsafe_load(rtlref).curr)
end
function rtlbind(t, sym, handle::cxxrtl_handle, val::String)
    rtlref = CxxrtlCosim.cxxrtl_get(handle, val)
    unsafe_store!(unsafe_load(rtlref).next, UInt32(sym))
    pt = prevt[]
    if t != pt # do timestep
        # println("from $pt to $t: $sym")
        prevt[] = t
        cxxrtl_step(handle)
    end
    unsafe_load(unsafe_load(rtlref).curr)
end

@register rtlget(t, handle::cxxrtl_handle, val::String)
@register rtlbind(t, sym, handle::cxxrtl_handle, val::String)