`timescale 1ns/1ns
`include "perceptron_branch_predictor.v"

module perceptron_branch_predictor_tb();

	integer scan_result;
	integer file_now;

	// variables for data files
	integer data_file_600;
	integer data_file_602;
	integer data_file_605;
	integer data_file_623;
	integer data_file_631;

	// variables for instruction count
	integer instruction_cnt_600;
	integer instruction_cnt_602;
	integer instruction_cnt_605;
	integer instruction_cnt_623;
	integer instruction_cnt_631;

	// variables for misprediction count
	integer misprediction_cnt_600;
	integer misprediction_cnt_602;
	integer misprediction_cnt_605;
	integer misprediction_cnt_623;
	integer misprediction_cnt_631;

	// control registers
	reg clk; // clock
	reg reset_n; // active low

	// data registers
	reg [63:0] ip; // instruction pointer
	reg [0:0] taken; // 1: taken, 0: not taken
	reg [0:0] prev_taken; // taken value of previous cycle

	wire [0:0] prediction; // taken (1) or not taken (0)

	// input registers
	reg [63:0] input_ip; // instruction pointer
	reg [0:0] input_taken; // 1: taken, 0: not taken

	perceptron_branch_predictor PBD(clk, reset_n, input_ip, prediction, input_taken);

	initial begin
		// initiate control registers
		clk = 0;
		reset_n = 1; // active low

		// initiate data registers
		ip = 0;
		taken = 0;
		prev_taken = 0;

		// initiate input registers
		input_ip = 0;
		input_taken = 0;

		// initiate instruction count variable
		instruction_cnt_600 = 0;
		instruction_cnt_602 = 0;
		instruction_cnt_605 = 0;
		instruction_cnt_623 = 0;
		instruction_cnt_631 = 0;

		// initiate misprediction count variable
		misprediction_cnt_600 = 0;
		misprediction_cnt_602 = 0;
		misprediction_cnt_605 = 0;
		misprediction_cnt_623 = 0;
		misprediction_cnt_631 = 0;

		// open data files
		data_file_600 = $fopen("branch_data/600_perlbench_branch_result.txt", "r");
		data_file_602 = $fopen("branch_data/602_gcc_branch_result.txt", "r");
		data_file_605 = $fopen("branch_data/605_mcf_branch_result.txt", "r");
		data_file_623 = $fopen("branch_data/623_xalancbmk_branch_result.txt", "r");
		data_file_631 = $fopen("branch_data/631_deepsjeng_branch_result.txt", "r");

		$display("perceptron predictor");

		// start from data file 600
		file_now = 600;
		// initial read
		FileReadTask();
		// give input: ip
		input_ip = ip;
	end

	always #50 clk <= ~clk;

	always @ (posedge clk) begin
		#50
		if(scan_result <= 0) begin
			// one test finished
			// reset predictor module
			reset_n = 0;
			reset_n = 1;

			// initiate registers
			taken = 0;
			prev_taken = 0;
			input_ip = 0;
			input_taken = 0;

			// read next
			FileReadTask();
			input_ip = ip;
		end
		else begin
			//$display("%d %d", prediction, taken);
			if(prediction != prev_taken) begin
				case(file_now)
					600: misprediction_cnt_600 = misprediction_cnt_600 + 1;
					602: misprediction_cnt_602 = misprediction_cnt_602 + 1;
					605: misprediction_cnt_605 = misprediction_cnt_605 + 1;
					623: misprediction_cnt_623 = misprediction_cnt_623 + 1;
					631: misprediction_cnt_631 = misprediction_cnt_631 + 1;
				endcase
			end

			// update previous taken
			prev_taken = taken;
			// update input taken with previous taken value
			input_taken = prev_taken;

			// read next
			FileReadTask();
			// update input ip, prev_taken
			input_ip = ip;
		end


		// end
		if(file_now == -1) begin
			$display("all finished");
			$display("================================");
			$display("test - 600:");
			$display("\tinstruction: %d", instruction_cnt_600);
			$display("\tmisprediction: %d", misprediction_cnt_600);
			$display("\tprediction accuracy: %.2f%%", (100.0 * (instruction_cnt_600 - misprediction_cnt_600)) / (instruction_cnt_600));
			$display("================================");
			$display("test - 602:");
			$display("\tinstruction: %d", instruction_cnt_602);
			$display("\tmisprediction: %d", misprediction_cnt_602);
			$display("\tprediction accuracy: %.2f%%", (100.0 * (instruction_cnt_602 - misprediction_cnt_602)) / (instruction_cnt_602));
			$display("================================");
			$display("test - 605:");
			$display("\tinstruction: %d", instruction_cnt_605);
			$display("\tmisprediction: %d", misprediction_cnt_605);
			$display("\tprediction accuracy: %.2f%%", (100.0 * (instruction_cnt_605 - misprediction_cnt_605)) / (instruction_cnt_605));
			$display("================================");
			$display("test - 623:");
			$display("\tinstruction: %d", instruction_cnt_623);
			$display("\tmisprediction: %d", misprediction_cnt_623);
			$display("\tprediction accuracy: %.2f%%", (100.0 * (instruction_cnt_623 - misprediction_cnt_623)) / (instruction_cnt_623));
			$display("================================");
			$display("test - 631:");
			$display("\tinstruction: %d", instruction_cnt_631);
			$display("\tmisprediction: %d", misprediction_cnt_631);
			$display("\tprediction accuracy: %.2f%%", (100.0 * (instruction_cnt_631 - misprediction_cnt_631)) / (instruction_cnt_631));
			$display("================================");
			$finish;
		end
	end

	task FileReadTask;
		begin
			scan_result = 1;

			if(file_now == 600) begin
				scan_result = $fscanf(data_file_600, "%d:%d", ip, taken);
				if(scan_result <= 0) begin
					file_now = 602;
					$display("test 600 finished");
				end
				else begin
					instruction_cnt_600 = instruction_cnt_600 + 1;
				end
			end
			else if(file_now == 602) begin
				scan_result = $fscanf(data_file_602, "%d:%d", ip, taken);
				if(scan_result <= 0) begin
					file_now = 605;
					$display("test 602 finished");
				end
				else begin
					instruction_cnt_602 = instruction_cnt_602 + 1;
				end
			end
			else if(file_now == 605) begin
				scan_result = $fscanf(data_file_605, "%d:%d", ip, taken);
				if(scan_result <= 0) begin
					file_now = 623;
					$display("test 605 finished");
				end
				else begin
					instruction_cnt_605 = instruction_cnt_605 + 1;
				end
			end
			else if(file_now == 623) begin
				scan_result = $fscanf(data_file_623, "%d:%d", ip, taken);
				if(scan_result <= 0) begin
					file_now = 631;
					$display("test 623 finished");
				end
				else begin
					instruction_cnt_623 = instruction_cnt_623 + 1;
				end
			end
			else if(file_now == 631) begin
				scan_result = $fscanf(data_file_631, "%d:%d", ip, taken);
				if(scan_result <= 0) begin
					$display("test 631 finished");
					file_now = -1;
				end
				else begin
					instruction_cnt_631 = instruction_cnt_631 + 1;
				end
			end
			else begin
				file_now = -1;
			end
		end
	endtask

endmodule
