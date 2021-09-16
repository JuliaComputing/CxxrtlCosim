using CxxrtlCosim
using ModelingToolkit
using OrdinaryDiffEq

cd(@__DIR__)

if !isfile("blinky.so")
    println("compiling blinky.v")
    CxxrtlCosim.synth("blinky.cpp", "blinky.v")
    CxxrtlCosim.compile("blinky.so", "blinky.cpp")
end

top = CxxrtlCosim.cxxrtl_design_create("./blinky.so")

blink = CxxrtlCosim.cxxrtl_create(top)
CxxrtlCosim.cxxrtl_reset(blink)

@parameters t::Int
@variables clk(t)::Int clkout(t)::Int led(t)::Int

D = Difference(t; dt=1)

eqs = [
    D(clk) ~ mod(clk+1, 2),
    D(clkout) ~ CxxrtlCosim.rtlbind(t, clk, blink, "clk"),
    D(led) ~ CxxrtlCosim.rtlget(t, blink, "led"),
]

@named de = DiscreteSystem(eqs,t,[clk, clkout, led], [])

u0 = [0, 0, 0]
prob = DiscreteProblem(de, u0, (0, 10000))
sol = solve(prob, FunctionMap())