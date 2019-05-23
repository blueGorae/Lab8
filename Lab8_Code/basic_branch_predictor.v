module basic_branch_predictor(clk, reset_n, input_ip, output_prediction, input_taken);
	input clk;
	input reset_n;

	input [63:0] input_ip;
	input [0:0] input_taken;
	output [0:0] output_prediction;

	reg [0:0] output_reg;

	// you can add more variables

	assign output_prediction = output_reg;

	initial begin
		output_reg <= 0;
	end


	always @ (*) begin
	end

	always @ (negedge reset_n) begin
		// reset all state asynchronously
		output_reg <= 0;
	end

	always @ (posedge clk) begin
	end

endmodule
