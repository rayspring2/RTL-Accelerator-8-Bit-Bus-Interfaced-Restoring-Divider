`timescale 1ns/1ns

module _8bitReg(input clk, input rst, input ld, input [7:0] ldData, output reg [7:0] Q);
	always @(posedge clk, posedge rst) begin
		if(rst)
			Q <= 0;
		else if(ld)
			Q <= ldData;
		else
			Q <= Q;
			
	end
endmodule


module _2bitCounter(input clk, rst, en, inz, output[1:0] out, output reg co);
	reg [1:0] ans;
	always @(posedge clk or posedge rst) begin
		if (rst)
			ans <= 0;
		else if(inz)
			ans <= 0;
		else if(en)
			ans <= ans + 1;
		else begin
			ans <= ans;
		end
	end	
	assign co = &ans;		
	assign out = ans;
endmodule

module _2to4Decoder(input en, input [1:0] sel, output [3:0]Q);
	 assign I = ~en ? 4'b0000 :
            (sel == 0) ? 4'b0001:
            (sel == 1) ? 4'b0010:
            (sel == 2) ? 4'b0100:
            (sel == 3) ? 4'b1000:
            4'b0000;
endmodule



module inwrapper(input clk, rst, input logic startData, input logic readyForInput, input ready,
		input [7:0] buss, output [15:0] A, output [15:0] B, 
		output logic ReadytoAccept, output logic startdivider);
	reg cnten, cntinz, cntco, dcden;
	wire [1:0] cntout;
	reg [3:0] enregs;
	reg [7:0] in [3:0];
	_2to4Decoder decoder(dcden, cntout, enregs);
	_8bitReg _0reg(clk, rst, enregs[0], buss, in[0]),
		_1reg(clk, rst, enregs[1], buss, in[1]),
		_2reg(clk, rst, enregs[2], buss, in[2]),
		_3reg(clk, rst, enregs[3], buss, in[3]);
	
	_2bitCounter counter(clk, rst, cnten, cntinz, cntout, cntco);
	typedef enum logic [3:0] {
	idle, 
	receive,
	waitForNext,
	waitForDivider,
	startDiv,
	procss
	} state;
	state ps, ns;
	always @(posedge clk, posedge rst) begin
		if(rst)
			ps <= idle;
		else
			ps <= ns;
	end
	
	always@(*) begin
		case(ps)
			idle : ns = (startData) ? receive : idle;
			receive : ns = (startData) ? receive : waitForNext;
			waitForNext : ns = (cntco) ?  waitForDivider : (startData) ? receive : waitForNext;
			waitForDivider : ns = (readyForInput) ? startDiv : waitForDivider;
			startDiv : ns = (ready) ? startDiv : procss;
			procss : ns = (ready) ? idle : procss;
		endcase
	end
	
	
	always@(*) begin
		ReadytoAccept = 0;
		cnten = 0;		
		case(ps)
			idle : begin ReadytoAccept = 1; cntinz = 1; end
			receive : dcden = 1;			
			waitForNext : begin ReadytoAccept = 1; cnten = (startData & ~cntco) ? 1 : 0; end
			startDiv : startdivider = 1;
		endcase
	end	
	
endmodule

module outwrapper(input clk, rst, input ready, input receivedData,
		input [15:0] Q, output [15:0] R, output [7:0] tothebuss, 
		output logic outbuffFull, output reg readyForInput);
		
	reg cnten, cntinz, cntco, cntout;
	_2bitCounter counter(clk, rst, cnten, cntinz, cntout, cntco);
		
		
	wire [7:0] collectedin[3:0];
	assign collectedin[0] = Q[31:8];
	assign collectedin[1] = Q[7:0];
	assign collectedin[2] = R[31:8];
	assign collectedin[3] = R[7:0];

	assign tothebuss = collectedin[cntout];
	
	typedef enum logic [3:0] {
		idle, 
		waitForBuss,
		waitForNext
	} state;
	state ps, ns;
	
	
	always @(posedge clk, posedge rst) begin
		if(rst)
			ps <= idle;
		else
			ps <= ns;
	end
	
	
	always@(*) begin
		case(ps)
			idle : ns = (ready) ? waitForBuss : idle;
			waitForBuss : ns = (receivedData) ? waitForNext : waitForBuss;
			waitForNext : ns = (cntco) ?  idle : (receivedData) ? waitForNext : waitForBuss;
			
		endcase
	end
	
	
	always@(*) begin
		readyForInput = 0;
		outbuffFull = 0;
		case(ps)
			idle : readyForInput = 1;
			waitForBuss : outbuffFull = 1;			
			waitForNext : cnten = (receivedData & ~cntco) ? 1 : 0;
		endcase
	end		
endmodule


module divTop(input clk, input rst, input startData, input receivedData, input [7:0] bussin,
                 output outbuffFull, ReadytoAccept, output [7:0] bussout);

    logic start, ready, RstDivider, readyForInput;
    wire [15:0] A, B;
    wire [15:0] Q,R; 

    divider divider(clk, rst, start, A, B, Q, R, ready);
    inwrapper inwrap(clk, rst, startData, readyForInput, Ready, 
					bussin, A, B, ReadytoAccept, start);


    outwrapper outwrap(clk, rst, ready, receivedData,
						Q, R, bussout, outbuffFull, readyForInput);
	
endmodule
	

			
	
	
	
	














