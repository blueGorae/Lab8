module two_level_branch_predictor(clk, reset_n, input_ip, output_prediction, input_taken);
	input clk;
	input reset_n;

	input [63:0] input_ip;
	input [0:0] input_taken;
	output [0:0] output_prediction;

	reg [0:0] output_reg;

	reg [1:0] state;

	// you can add more variables

	assign output_prediction = output_reg;

	initial begin
		output_reg <= 0;
		state <= 2'b00;
	end


	always @ (*) begin
		case(state)
			2'b00 : output_reg = input_taken ? 0 : 0; 
			2'b01 : output_reg = input_taken ? 1 : 0;
			2'b10 : output_reg = input_taken ? 1 : 0;
			2'b11 : output_reg = input_taken ? 1 : 1;

	end

	always @ (negedge reset_n) begin
		// reset all state asynchronously
		output_reg <= 0;
		state <= 2'b00;
	end

	always @ (posedge clk) begin
		case(state)
				2'b00 : state = input_taken ? 2'b01 : 2'b00; 
				2'b01 : state = input_taken ? 'b10 : 'b00;
				2'b10 : state = input_taken ? 'b11 : 'b01;
				2'b11 : state = input_taken ? 'b11 : 'b10;
	end

endmodule
