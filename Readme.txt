Name : Shaikh Moin Dastagir
Roll : 16CS30033


*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/Loopholes And Limitations*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/*/*/*/

Shortcomings:
1. For passing the arguments we only have 4 registers %rdi,%rsi,%rdx,%rcx which limits the number of arguments passed to 4 unlike the other cases like for temporary variables where stack is used which provides more flexibility. These registers store their value in the function stack of n entering the required nested function. 
2. As we made a compiler for Tiny - C . Only the functionalities required by the assignments are implemented, like type conversions are not supported. 
3. The functions for I/O are very limited as only those functions defined in the assembly can be used .  


*********************************************Tiny C compiler*************************************************************
Commands: 

1) To do everything from compiling to generating quads and generating assembly code and generating executables from the test files
	type : make  all 

2) To make an executable for a particular test case 
	type : make test#                                   // Where #->test number

3) To run the executable of the particular test case: 
	type : ./test#                                 // Where #->test number
4) make clean --- To delete all the generated files