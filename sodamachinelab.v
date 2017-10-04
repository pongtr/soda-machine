module sodamachinelab (
	 // Inputs from CAM switches
	 input wire GPIO_0_PIN_13,
	 input wire GPIO_0_PIN_15,
	 input wire GPIO_0_PIN_17,
	 input wire GPIO_0_PIN_19,
	 input wire GPIO_0_PIN_21,
	 input wire GPIO_0_PIN_23,
	 input wire GPIO_0_PIN_25,
	 input wire GPIO_0_PIN_27,
	 // Inputs from soldout switches
	 input wire GPIO_0_PIN_31,
	 input wire GPIO_0_PIN_32,
	 input wire GPIO_0_PIN_33,
	 input wire GPIO_0_PIN_34,
	 input wire GPIO_0_PIN_35,
	 input wire GPIO_0_PIN_36,
	 input wire GPIO_0_PIN_37,
	 input wire GPIO_0_PIN_38,

	 // Outputs to motors
	 output wire GPIO_0_PIN_14,
	 output wire GPIO_0_PIN_16,
	 output wire GPIO_0_PIN_18,
	 output wire GPIO_0_PIN_20,
	 output wire GPIO_0_PIN_22,
	 output wire GPIO_0_PIN_24,
	 output wire GPIO_0_PIN_26,
	 output wire GPIO_0_PIN_28,

	 // Inputs from select switches
	 input wire GPIO_1_PIN_13,
	 input wire GPIO_1_PIN_15,
	 input wire GPIO_1_PIN_17,
	 input wire GPIO_1_PIN_19,
	 input wire GPIO_1_PIN_21,
	 input wire GPIO_1_PIN_23,
	 input wire GPIO_1_PIN_25,

	 // Input from coin acceptor
	 input wire GPIO_1_PIN_27,

	 // Outputs to soda lamps
	 output wire GPIO_1_PIN_14,
	 output wire GPIO_1_PIN_16,
	 output wire GPIO_1_PIN_18,
	 output wire GPIO_1_PIN_20,
	 output wire GPIO_1_PIN_22,
	 output wire GPIO_1_PIN_24,
	 output wire GPIO_1_PIN_26,
	 output wire GPIO_1_PIN_28,
	 // FPGA LEDs, buttons and clock source
	 output wire [7:0] ledg,
	 output wire [9:0] ledr,
	 input wire [3:0] key,
	 input wire [9:0] sw,
	 input wire clock
);
// Internal wires and registers
wire [7:0] CAM;
wire [7:0] soldoutsw;
reg [7:0] vendingmotors;
wire [6:0] selectsw;
wire coinchanger;
wire [7:0] soldoutled;
// Assign pins to internal wires for ease of reading and coding
//assign CAM[0] = GPIO_0_PIN_13;
assign CAM[0] = 1;
assign CAM[1] = 1;//GPIO_0_PIN_15;
assign CAM[2] = sw[0];//GPIO_0_PIN_17;
assign CAM[3] = 1;//GPIO_0_PIN_19;
assign CAM[4] = 1;//GPIO_0_PIN_21;
assign CAM[5] = 1;//GPIO_0_PIN_23;
assign CAM[6] = 1;//GPIO_0_PIN_25;
assign CAM[7] = 1;//GPIO_0_PIN_27;
//assign soldoutsw[0] = GPIO_0_PIN_31;
assign soldoutsw[0] = 1;
assign soldoutsw[1] = 1;//GPIO_0_PIN_32;
assign soldoutsw[2] = sw[1];//GPIO_0_PIN_33;
assign soldoutsw[3] = 1;//GPIO_0_PIN_34;
assign soldoutsw[4] = 1;//GPIO_0_PIN_35;
assign soldoutsw[5] = 1;//GPIO_0_PIN_36;
assign soldoutsw[6] = 1;//GPIO_0_PIN_37;
assign soldoutsw[7] = 1;//GPIO_0_PIN_38;

//assign GPIO_0_PIN_14 = vendingmotors[0];
assign ledg[0] = vendingmotors[2];
/*assign GPIO_0_PIN_16 = vendingmotors[1];
assign GPIO_0_PIN_18 = vendingmotors[2];
assign GPIO_0_PIN_20 = vendingmotors[3];
assign GPIO_0_PIN_22 = vendingmotors[4];
assign GPIO_0_PIN_24 = vendingmotors[5];
assign GPIO_0_PIN_26 = vendingmotors[6];
assign GPIO_0_PIN_28 = vendingmotors[7];*/

//assign selectsw[0] = GPIO_1_PIN_13;
assign selectsw[0] = 0;
assign selectsw[1] = sw[2];//GPIO_1_PIN_15;
assign selectsw[2] = 0;//GPIO_1_PIN_17;
assign selectsw[3] = 0;//GPIO_1_PIN_19;
assign selectsw[4] = 0;//GPIO_1_PIN_21;
assign selectsw[5] = 0;//GPIO_1_PIN_23;
assign selectsw[6] = 0;//GPIO_1_PIN_25;
//assign coinchanger = GPIO_1_PIN_27;
assign coinchanger = sw[3];
/*assign GPIO_1_PIN_14 = soldoutled[0];
assign GPIO_1_PIN_16 = soldoutled[1];
assign GPIO_1_PIN_18 = soldoutled[2];
assign GPIO_1_PIN_20 = soldoutled[3];
assign GPIO_1_PIN_22 = soldoutled[4];
assign GPIO_1_PIN_24 = soldoutled[5];
assign GPIO_1_PIN_26 = soldoutled[6];
assign GPIO_1_PIN_28 = soldoutled[7];*/

assign ledr[6:0] = Sreg;
assign ledr[9:7] = Xnext;

reg [6:0] Sreg, Snext;					// State register and next state
reg [2:0] Xreg, Xnext;					// Registers to store X

assign soldoutled[0] 	= ~(soldoutsw[0] & soldoutsw[1]);
assign soldoutled[7:2]	= ~(soldoutsw[6:1]);

/////////////////////////////////////////////////////////////////////////
/////////////////////////// DEFINE THE STATES ///////////////////////////
/////////////////////////////////////////////////////////////////////////
parameter [4:0] 	WAIT	= 5'b00001,
						
						// Secret Code
						SC1	= 5'b00100,
						SC17	= 5'b00101,
						SC175	= 5'b00110,
						
						VEND	= 5'b00111,
						
						SEL0	= 5'b10000, // Select 0 is special case
						V0		= 5'b11000,
						V1		= 5'b11001,
						SEL1	= 5'b10001,
						SEL2	= 5'b10010,
						SEL3	= 5'b10011,
						SEL4	= 5'b10100,
						SEL5	= 5'b10101,
						SEL6	= 5'b10110,
												
						// Select and vend
						SEL	= 5'b01001,
						VENX	= 5'b01010,
						CA1X	= 5'b01011,
						CA2X	= 5'b01100,
						CA3X	= 5'b01101,
						CA4X	= 5'b01110;
						


///////////////////////////////////////////////////////////////////////////
/////////////////////////// CREATE STATE MEMORY ///////////////////////////
///////////////////////////////////////////////////////////////////////////
always @ (posedge clock) begin
	Sreg <= Snext;
	Xreg <= Xnext;
end
	
////////////////////////////////////////////////////////////////////////
/////////////////////////// NEXT STATE LOGIC ///////////////////////////
////////////////////////////////////////////////////////////////////////
always @ (Sreg, CAM [7:0], soldoutsw[7:0], selectsw[6:0], coinchanger, Xreg) begin
	case (Sreg)
		WAIT:		if (coinchanger == 1)		Snext = VEND;
					else if (selectsw[0]==1)	Snext = SC1;
					else								Snext = WAIT;
		// Secret Code
		SC1:		if (coinchanger==1)			Snext = VEND;
					else if (selectsw[6]==1)	Snext = SC17;
					else								Snext = WAIT;
		SC17:		if (coinchanger==1)			Snext = VEND;
					else if (selectsw[4]==1)	Snext = SC175;
					else if (selectsw[0]==1)	Snext = SC1;
					else								Snext = WAIT;
		SC175:	if (coinchanger==1)			Snext = VEND;
					else if (selectsw[1]==1)	Snext = VEND;
					else if (selectsw[0]==1)	Snext = SC1;
					else								Snext = WAIT;
		
		
		VEND:		if (selectsw[0]==1)			Snext = SEL0;
					else if (selectsw[1]==1)	Snext = SEL1;
					else if (selectsw[2]==1)	Snext = SEL2;
					else if (selectsw[3]==1)	Snext = SEL3;
					else if (selectsw[4]==1)	Snext = SEL4;
					else if (selectsw[5]==1)	Snext = SEL5;
					else if (selectsw[6]==1)	Snext = SEL6;
					else								Snext = VEND;
					
		// Select 0 is special case
		SEL0: 	if (soldoutsw[0]==1
							&& soldoutsw[1]==1)	Snext = VEND; // wait for select
					else if (soldoutsw[0]==0)	Snext = V0; // vend 0
					else if (soldoutsw[1]==0)	Snext = V1; // vend 1
		V0:		if (soldoutsw[0]==1)			Snext = VEND;
					else 								Snext = VENX;
		V1:		if (soldoutsw[1]==1)			Snext = VEND;
					else 								Snext = VENX;
		SEL1:		if (soldoutsw[2]==1)			Snext = VEND;
					else								Snext = VENX;
		SEL2:		if (soldoutsw[3]==1)			Snext = VEND;
					else								Snext = VENX;
		SEL3:		if (soldoutsw[4]==1)			Snext = VEND;
					else								Snext = VENX;
		SEL4:		if (soldoutsw[5]==1)			Snext = VEND;
					else								Snext = VENX;
		SEL5:		if (soldoutsw[6]==1)			Snext = VEND;
					else								Snext = VENX;
		SEL6:		if (soldoutsw[7]==1)			Snext = VEND;
					else								Snext = VENX;
		
		// Select and vend
		/*SELX:		if (soldoutsw[Xreg]==1)		Snext = VEND;
					else								Snext = VENX;*/
		VENX:		if (CAM[Xreg]==0)				Snext = CA1X;
					else								Snext = VENX;
		CA1X:		if (CAM[Xreg]==1)				Snext = CA2X;
					else								Snext = CA1X;
		CA2X:		if (CAM[Xreg]==0)				Snext = CA3X;
					else								Snext = CA2X;
		CA3X:		if (CAM[Xreg]==1)				Snext = CA4X;
					else								Snext = CA3X;
		CA4X:		Snext = WAIT;
		default	Snext = Sreg;
	endcase
end


////////////////////////////////////////////////////////////////////
/////////////////////////// OUTPUT LOGIC ///////////////////////////
////////////////////////////////////////////////////////////////////
always @ (Sreg)
	case (Sreg)
		WAIT:   	begin Xnext = 0; end 
		V0:		begin Xnext = 0; end
		V1:		begin Xnext = 1; end
		SEL1:		begin Xnext = 2; end
		SEL2:		begin Xnext = 3; end
		SEL3:		begin Xnext = 4; end
		SEL4:		begin Xnext = 5; end
		SEL5:		begin Xnext = 6; end
		SEL6:		begin Xnext = 7; end
		VENX:		begin Xnext = Xreg; end
		default	Xnext = Xreg; 
	endcase

always @ (Sreg)
	case (Sreg)
		VENX, CA1X, CA2X, CA3X: vendingmotors[Xreg] = 1;
		default vendingmotors[7:0] = 0;
	endcase
	
endmodule
