module missionary_cannibal (clk, reset, missionary_next, cannibal_next, finish);
// top module
	input clk, reset;
	output[1:0] missionary_next;
	output[1:0] cannibal_next;
	output finish;

// output from direction module. will contain direction, so also used as input for combLogic instance
	wire dir;

// input for direction module
	wire dirInput;

// wires between state registers and combLogic (current state)
// also used on INITDIR gate
	wire [1:0] curr_m;
	wire [1:0] curr_c;

// wires with output from combLogic (next state)
	wire [1:0] next_m;
	wire [1:0] next_c;

// wire used to check if direction needs to be initialized
	wire initDir;

// connect wires to output ports
	assign missionary_next = next_m;
	assign cannibal_next = next_c;

	// instances of submodules
	fourBitReg stateReg (clk, reset, next_c, next_m, curr_c, curr_m);
	firstTermPrj combLogic (curr_m, curr_c, dir, next_m, next_c);
	dirReg direction (dir, dirInput, clk, reset);

	// finished if next state is 0000, and direction is 1
	and FINISH (finish, !next_c[1], !next_c[0], !next_m[1], !next_m[0], dir);

	// checks if state could have been initialized internally in combLogic
	and INITDIR (initDir, next_c[0], next_c[1], next_m[1], next_m[0], !curr_c[0], !curr_c[1], !curr_m[1], !curr_m[0]);

	// makes sure direction module gets correct input, so that it is initialized if needed
	and DIRINPUT (dirInput, !initDir, dir);

  endmodule // end missionary_cannibal(top module)


module fourBitReg (clck, reset, next_c, next_m, curr_c, curr_m);
	// register module which will contain current state
	// consists of four instances of stateRegister (DFF), each storing one bit
	input clck, reset;
	input [1:0] next_c;
	input [1:0] next_m;
	output [1:0] curr_c;
	output [1:0] curr_m;

	wire r1, r2, r3, r4;

	stateRegister reg1 (r1, next_m[1], clck, reset);
	stateRegister reg2 (r2 , next_m[0], clck, reset);
	stateRegister reg3 (r3 , next_c[1], clck, reset);
	stateRegister reg4 (r4 , next_c[0], clck, reset);

	assign curr_m[1] = r1;
	assign curr_m[0] = r2;
	assign curr_c[1] = r3;
	assign curr_c[0] = r4;

	endmodule // end fourBitReg

	module stateRegister (Q, D, clk, rst);
	// DFF used as register to store one bit
	// set to 1 in case of reset
		output Q;
		input D, clk, rst;

		reg Q;

	always @ (posedge clk or posedge rst)
	begin
		if (rst) Q = 1'b1;
		else Q = D;
	end
	endmodule // end stateRegister


	module dirReg (Q, D, clk, rst);
	// register used to find and store direction
	// In order to make it alternate between 0 and 1, the input is its previous output
	// The output is then the complement of the input
		output Q;
		input D, clk, rst;

		reg Q;

	always @ (posedge clk or posedge rst)
	begin
		if (rst) Q = 1'b0;
		else Q = !D;
	end
	endmodule //end dirReg


	module firstTermPrj (missionary_curr, cannibal_curr, direction, missionary_next, cannibal_next);
		// same as in term project 1
		input[1:0] missionary_curr;
		input[1:0] cannibal_curr;
		input direction;
		output [1:0] missionary_next;
		output [1:0] cannibal_next;

		wire s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17;


		and S1(s1, !missionary_curr[1], missionary_curr[0]); /* s1 = A'B */
		and S2(s2, !cannibal_curr[1], !cannibal_curr[0]); /* s2 = C'D' */
		and S3(s3, !missionary_curr[0], !cannibal_curr[1], direction); /* s3 = B'C'E */
		and S4(s4, missionary_curr[0], cannibal_curr[1]); /* s4 = BC */
		and S5(s5, cannibal_curr[1], cannibal_curr[0], !direction); /* s5 = CDE' */
		and S6(s6, missionary_curr[1], !direction); /* s6 = AE' */
		and S7(s7, missionary_curr[1], !missionary_curr[0], cannibal_curr[0]); /* s7 = AB'D */
		and S8(s8, missionary_curr[1], cannibal_curr[0]); /* s8 = AD */
		and S9(s9, !cannibal_curr[1], direction); /* s9 = C'E */
		and S10(s10, missionary_curr[1], !missionary_curr[0]); /* s10 = AB' */
		and S11(s11, cannibal_curr[0], !direction); /* s11 = DE' */
		and S12(s12, !missionary_curr[1], !cannibal_curr[1]); /* s12 = A'C' */
		and S13(s13, cannibal_curr[1], !direction); /* s13 = CE' */
		and S14(s14, !cannibal_curr[1], !cannibal_curr[0], direction); /* s14 = C'D'E */
		and S15(s15, cannibal_curr[0], direction); /* s15 = DE */
		and S16(s16, missionary_curr[1], !missionary_curr[0], !cannibal_curr[1]); /* s16 = AB'C' */
		and S17(s17, !missionary_curr[1], missionary_curr[0], cannibal_curr[1]); /* s17 = A'BC */


		/*
		F1 =  s1 + s2 + s3 + s4 + s5 + s6 + s7
		   =  A'B + C'D' + B'C'E + BC + CDE' + AE' + AB'D
		*/
		or F1(missionary_next[1], s1, s2, s3, s4, s5, s6, s7);

		/*
		F2 = s4 + s2 + s8 + s6 + s9 + s5
		   = BC + C'D' + AD + AE' + C'E + CDE'
		*/
		or F2(missionary_next[0], s4, s2, s8, s6, s9, s5);

		/*
		F3 = s1 + s10 + s11 + s12 + s13 + s14
		   = A'B + AB' + DE' + A'C' + CE' C'D'E
		*/
		or F3(cannibal_next[1], s1, s10, s11, s12, s13, s14);

		/*
		F4 = s2 + s15 + s13 + s16 + s17
		   = C'D' + DE + CE' + AB'C' + A'BC
		*/
		or F4(cannibal_next[0], s2, s15, s13, s16, s17);

	endmodule //end firstTermPrj
