# CxxrtlCosim
Cosimulation of ModelingToolkit.jl and cxxrtl

This project is a Julia interface to Yosys's cxxrtl C API, which allows driving a HDL model from Julia.
It supports any HDL that can be parsed by Yosys, including VHDL, Verilog, nMigen and many more.

On top of that it provides a ModelingToolkit function for binding symbols to cxxrtl variables.
This way a HDL model can be embedded in a `DiscreteSystem`.

In the future, a `DiscreteSystem` will be able to be promoted to an `ODESystem`, allowing full mixed signal cosimulation between HDL models and MTK models.

For examples, please see the `test` folder.

This project uses Clang.jl to generate Julia bindings for cxxrtl, for which the generator resides in the `gen` folder.
