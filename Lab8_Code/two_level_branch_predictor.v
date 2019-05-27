
module two_level_branch_predictor(clk, reset_n, input_ip, output_prediction, input_taken);
	input clk;
	input reset_n;

	input [63:0] input_ip;
	input [0:0] input_taken;
	output [0:0] output_prediction;

	reg [0:0] output_reg;

	reg [1 : 0] branch_table [0:63];
	reg [1 : 0] state;

	reg [5:0] prev_index; //6bit version

	reg [5:0] BHSR;
	integer i;

	// you can add more variables

	assign output_prediction = output_reg;

	initial begin
		BHSR <= 6'b0;
		output_reg <= 0;
		state <= 2'b00;
		prev_index <= 6'b0;
		for(i = 0; i < 64; i = i+ 1) begin
			branch_table[i] = 2'b00;
		end

	end


	always @ (*) begin
		case(state)
			2'b00 : output_reg = 0; 
			2'b01 : output_reg = 0;
			2'b10 : output_reg = 1;
			2'b11 : output_reg = 1;
		endcase
	end

	always @ (negedge reset_n) begin
		// reset all state asynchronously
		
		BHSR <= 6'b0;
		output_reg <= 0;
		state <= 2'b00;
		prev_index <= 6'b0;
		for(i = 0; i < 64; i = i+ 1) begin
			branch_table[i] = 2'b00;
		end

	end

	always @ (posedge clk) begin
		state = branch_table[BHSR];

		case (branch_table[prev_index])
			2'b00 : branch_table[prev_index] = input_taken ? 2'b01 : 2'b00;
			2'b01 : branch_table[prev_index] = input_taken ? 2'b10 : 2'b00;
			2'b10 : branch_table[prev_index] = input_taken ? 2'b11 : 2'b01;
			2'b11 : branch_table[prev_index] = input_taken ? 2'b11 : 2'b10;
		endcase		

		prev_index = BHSR;
		BHSR = BHSR << 1;
		BHSR[0] = input_taken;

	end

endmodule
