module perceptron_branch_predictor(clk, reset_n, input_ip, output_prediction, input_taken);
	input clk;
	input reset_n;

	input [63:0] input_ip;
	input [0:0] input_taken;
	output [0:0] output_prediction;

	reg [0:0] output_reg;
	reg [0:0] prev_prediction; 
	integer perceptron_table [0:61][7:0];
	integer y;

	reg [0:7] prev_BHSR;
	reg [0:7] BHSR;

	reg [5:0] index;
	reg [5:0] prev_index;

	integer i;
	integer j;

	integer global_x;
	integer t;

	// you can add more variables

	assign output_prediction = output_reg;

	initial begin

		for(i = 0; i < 62; i = i+ 1) begin
			for(j = 0; j < 8 ; j = j + 1) begin
				perceptron_table[i][j] = 0;
			end
		end

		y <=0;
		global_x <= 1;
		t <= 1;
		prev_BHSR <= 0;
		BHSR <= 0;

		index <= 0;
		prev_index <= 0;

		output_reg <= 0;
		prev_prediction <= 0;

	end

	always @ (*) begin
		if ($signed(y) < 0) begin
			output_reg = 0;
		end else begin
			output_reg = 1;
		end
	end

	always @ (negedge reset_n) begin
		// reset all state asynchronously
		for(i = 0; i < 62; i = i+ 1) begin
			for(j = 0; j < 8 ; j = j + 1) begin
				perceptron_table[i][j] = 0;
			end
		end

		y <=0;
		global_x <= 1;
		t <= 1;

		prev_BHSR <= 0;
		BHSR <= 0;

		index <= 0;
		prev_index <= 0;

		output_reg <= 0;
		prev_prediction <= 0;
	end

	always @ (posedge clk) begin
		BHSR = BHSR << 1;
		BHSR[0] = 1; // bias
		BHSR[7] = input_taken;

		index = input_ip%62;
		y = 0;
		for(i = 0 ; i < 8 ; i = i + 1) begin
			global_x = BHSR[i] == 1 ? 1 : -1;
			y = y + perceptron_table[index][i] * global_x;
		end

		if(input_taken != prev_prediction) begin
			for( i = 0 ; i < 8 ; i = i + 1) begin
				global_x = prev_BHSR[i] == 1 ? 1 : -1;
				t = prev_prediction == 1 ? 1 : -1;
				perceptron_table[prev_index][i] = perceptron_table[prev_index][i]+ prev_prediction* prev_BHSR[i];
			end
		end

		prev_index = index;
		prev_BHSR = BHSR;
		prev_prediction = output_reg;
	end
endmodule
