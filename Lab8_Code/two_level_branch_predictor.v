
module two_level_branch_predictor(clk, reset_n, input_ip, output_prediction, input_taken);
	input clk;
	input reset_n;

	input [63:0] input_ip;
	input [0:0] input_taken;
	output [0:0] output_prediction;

	reg [0:0] output_reg;

	reg [66:0] branch_table [0:255];
	reg [1 : 0] state;



	// you can add more variables

	assign output_prediction = output_reg;
	integer i;

	initial begin
		output_reg <= 0;
		state <= 2'b00;
		for(i = 0; i < 256; i = i+ 1) begin
			branch_table[i] = 67'b0;
		end
	end


	always @ (*) begin
		for(i = 0; i < 256; i = i+1) begin
			if((input_ip == branch_table[i][66 : 3]) && branch_table[i][2]) begin
				state = branch_table[i][1:0];
				break;
			end
		end
		for(i = 0; i < 256; i = i+1) begin
			if(branch_table[i][2] == 0) begin
				branch_table[i][66 : 3] = input_ip;
				state = 2'b00;
				brach_table[i][2] = 1;
				break;
			end
		end
		case(state)
			2'b00 : output_reg = input_taken ? 0 : 0; 
			2'b01 : output_reg = input_taken ? 1 : 0;
			2'b10 : output_reg = input_taken ? 1 : 0;
			2'b11 : output_reg = input_taken ? 1 : 1;
		endcase

	end

	always @ (negedge reset_n) begin
		// reset all state asynchronously
		output_reg <= 0;
		state <= 2'b00;
		for(i = 0; i < 256; i = i+ 1) begin
			branch_table[i] = 67'b0;
		end
	end

	always @ (posedge clk) begin
		case(state)
			2'b00 : state = input_taken ? 2'b01 : 2'b00; 
			2'b01 : state = input_taken ? 2'b10 : 2'b00;
			2'b10 : state = input_taken ? 2'b11 : 2'b01;
			2'b11 : state = input_taken ? 2'b11 : 2'b10;
		endcase
	end

endmodule
