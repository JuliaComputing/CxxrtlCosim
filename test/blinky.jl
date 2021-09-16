using CxxrtlCosim

cd(@__DIR__)

if !isfile("blinky.so")
    println("compiling blinky.v")
    CxxrtlCosim.synth("blinky.cpp", "blinky.v")
    CxxrtlCosim.compile("blinky.so", "blinky.cpp")
end

top = CxxrtlCosim.cxxrtl_design_create("./blinky.so")

blink = CxxrtlCosim.cxxrtl_create(top)

clk = CxxrtlCosim.cxxrtl_get(blink, "clk")
led = CxxrtlCosim.cxxrtl_get(blink, "led")

CxxrtlCosim.cxxrtl_reset(blink)

CxxrtlCosim.cxxrtl_step(blink)
prev_led = 0
for i = 1:10000
    unsafe_store!(unsafe_load(clk).next, UInt32(1))
    CxxrtlCosim.cxxrtl_step(blink)
    unsafe_store!(unsafe_load(clk).next, UInt32(0))
    CxxrtlCosim.cxxrtl_step(blink)
    global ledval = unsafe_load(unsafe_load(led).curr)
    if prev_led != ledval
        println("$i: $ledval")
        global prev_led = ledval
    end
end