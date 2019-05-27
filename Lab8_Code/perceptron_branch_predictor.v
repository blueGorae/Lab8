module perceptron_branch_predictor(clk, reset_n, input_ip, output_prediction, input_taken);
	input clk;
	input reset_n;

	input [63:0] input_ip;
	input [0:0] input_taken;
	output [0:0] output_prediction;

	reg [0:0] output_reg;
	reg [0:0] prev_prediction; 
	integer perceptron_table [0:6][0:62];
	integer y;
	integer prev_y;
	integer product_result;

	reg [0:62] prev_BHSR;
	reg [0:62] BHSR;

	reg unsigned [2:0]  index;
	reg unsigned [2:0] prev_index;

	integer i;
	integer j;

	integer global_x;
	integer t;
	integer threshold;
	// you can add more variables

	assign output_prediction = output_reg;

	initial begin
		threshold <= 133;
		for(i = 0; i < 7; i = i+ 1) begin
			for(j = 0; j < 63 ; j = j + 1) begin
				perceptron_table[i][j] = 0;
			end
		end

		y <=0;
		prev_y <= 0;

		product_result <= 0;

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
		if ($signed(y) <= 0) begin
			output_reg = 0;
		end else begin
			output_reg = 1;
		end
	end

	always @ (negedge reset_n) begin
		// reset all state asynchronously

		threshold <= 133;

		for(i = 0; i < 7; i = i+ 1) begin
			for(j = 0; j <63 ; j = j + 1) begin
				perceptron_table[i][j] = 0;
			end
		end

		y <=0;
		prev_y <= 0;
		product_result <= 0;

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
		BHSR[62] = input_taken;

		index = $unsigned(input_ip%7);
		y = 0;
		product_result = 0;
		for(i = 0 ; i < 63 ; i = i + 1) begin
			global_x = BHSR[i] == 1 ? 1 : -1;
			product_result = product_result + perceptron_table[index][i] * global_x;
			// $display("perceptron element : %d, global_x : %d\n",perceptron_table[index][i], global_x );
			// $display("product entry : %d\n",perceptron_table[index][i] * global_x );
		end
		y = product_result;

		if(input_taken != prev_prediction || (prev_y < threshold && prev_y > (-threshold))) begin
			for( i = 0 ; i < 63 ; i = i + 1) begin
				global_x = prev_BHSR[i] == 1 ? 1 : -1;
				t = input_taken == 1 ? 1 : -1;
				perceptron_table[prev_index][i] = perceptron_table[prev_index][i]+ t * global_x;
			end
		end

		prev_y = y;
		prev_index = index;
		prev_BHSR = BHSR;
		prev_prediction = output_reg;
	end
endmodule
