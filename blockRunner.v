module blockRunner(
    input wire CLK,             // board clock: 100 MHz on Arty/Basys3/Nexys
    input wire RST_BTN,         // reset button
    output wire VGA_HS_O,       // horizontal sync output
    output wire VGA_VS_O,       // vertical sync output
    output reg [3:0] VGA_R,     // 4-bit VGA red output
    output reg [3:0] VGA_G,     // 4-bit VGA green output
    output reg [3:0] VGA_B,     // 4-bit VGA blue output
	 output wire a, ba, c, d, e, f, g,
	 output wire a1, ba1, c1, d1, e1, f1, g1,
	 output wire a2, ba2, c2, d2, e2, f2, g2,
	 output wire a3, ba3, c3, d3, e3, f3, g3,
	 input SW0,
	 input KEY0,
	 input KEY1,
	 input KEY2,
	 input KEY3
    );

    wire rst = ~RST_BTN;    // reset is active low on Arty & Nexys Video
    // wire rst = RST_BTN;  // reset is active high on Basys3 (BTNC)

    // generate a 25 MHz pixel strobe
    reg [15:0] cnt;
    reg pix_stb;
    always @(posedge CLK)
        {pix_stb, cnt} <= cnt + 16'h8000;  // divide by 4: (2^16)/4 = 0x4000

    wire [9:0] x;  // current pixel x position: 10-bit value: 0-1023
    wire [8:0] y;  // current pixel y position:  9-bit value: 0-511

    vga640x480 display (
        .i_clk(CLK),
        .i_pix_stb(pix_stb),
        .i_rst(rst),
        .o_hs(VGA_HS_O),
        .o_vs(VGA_VS_O),
        .o_x(x),
        .o_y(y)
    );

/***********************************************************************************************************************/
	 
// VGA Wire Objects

/***********************************************************************************************************************/

   wire backDrop, sun, moon, cloud, cloud2, cloud3;
   assign backDrop = ((x > 0) & (y > 300) & (x < 640) & (y < 477)) ? 1 : 0;
	assign sun = ((x > 475) & (y > 50) & (x < 550) & (y < 125)) ? 1 : 0;
	assign moon = ((x > 475) & (y > 50) & (x < 550) & (y < 125)) ? 1 : 0;
	assign cloud = ((x > cloud1X) & (x < cloud1Width + cloud1X) & (y > 75) & (y < 125)) ? 1 : 0;
	assign cloud2 = ((x > cloud2X) & (x < cloud2Width + cloud2X) & (y > 100) & (y < 150)) ? 1 : 0;
	assign cloud3 = ((x > cloud3X) & (x < cloud3Width + cloud3X) & (y > 85) & (y < 135)) ? 1 : 0;
	assign star = ((x > 20) & (x < 25) & (y > 50) & (y < 55)) ? 1 : 0;
	assign star1 = ((x > 70) & (x < 75) & (y > 125) & (y < 130)) ? 1 : 0;
	assign star2 = ((x > 100) & (x < 105) & (y > 30) & (y < 35)) ? 1 : 0;
	assign star3 = ((x > 150) & (x < 155) & (y > 65) & (y < 70)) ? 1 : 0;
	assign star4 = ((x > 200) & (x < 205) & (y > 20) & (y < 25)) ? 1 : 0;
	assign star5 = ((x > 240) & (x < 245) & (y > 80) & (y < 85)) ? 1 : 0;
	assign star6 = ((x > 300) & (x < 305) & (y > 90) & (y < 95)) ? 1 : 0;
	assign star7 = ((x > 340) & (x < 345) & (y > 40) & (y < 45)) ? 1 : 0;
	assign star8 = ((x > 410) & (x < 415) & (y > 75) & (y < 80)) ? 1 : 0;
	assign star9 = ((x > 450) & (x < 455) & (y > 90) & (y < 95)) ? 1 : 0;
	
	assign o1left = ((x > 90) & (y > 120) & (x < 120) & (y < 250)) ? 1 : 0;
	assign o1right = ((x > 190) & (y > 120) & (x < 220) & (y < 250)) ? 1 : 0;
	assign o1top = ((x > 90) & (y > 120) & (x < 220) & (y < 150)) ? 1 : 0;
	assign o1bottom = ((x > 90) & (y > 220) & (x < 220) & (y < 250)) ? 1 : 0;

	assign o2left = ((x > 285) & (y > 120) & (x < 315) & (y < 250)) ? 1 : 0;
	assign o2right = ((x > 385 ) & (y > 120) & (x < 415) & (y < 250 )) ? 1 : 0;
	assign o2top = ((x > 285) & (y > 120) & (x < 415) & (y < 150)) ? 1 : 0;
	assign o2bottom = ((x > 285) & (y > 220) & (x < 415) & (y < 250)) ? 1 : 0;

	assign fleft = ((x > 480) & (y > 120) & (x < 510) & (y <  250)) ? 1 : 0;
	assign ftop = ((x > 490) & (y > 120) & (x < 570) & (y < 150)) ? 1 : 0;
	assign fbottom = ((x > 490) & (y > 180) & (x < 550) & (y < 210)) ? 1 : 0;

/***********************************************************************************************************************/
	 
// Cloud logic

/***********************************************************************************************************************/
	reg[9:0] cloud1X, cloud2X, cloud3X;
	reg[9:0] cloud1Width, cloud2Width, cloud3Width;
	reg nightToggle, dayToggle;

always@(posedge CLK)
	begin
		case(s)
			menu: begin
					cloud1X <= 10'd110;
					cloud2X <= 10'd300;
					cloud3X <= 10'd10;
					cloud1Width <= 10'd100;
					cloud2Width <= 10'd100;
					cloud3Width <= 10'd90;
					nightToggle <= 1'd0;
					dayToggle <= 1'd1;
					
					end
			playingDay: begin
						if(countTime >= 49_999_990)
							begin
								cloud1X <= cloud1X + 3'd2;
								cloud2X <= cloud2X + 1'd1;
								cloud3X <= cloud3X + 1'd1;
							end
						if(countDayNight >= 20)
							begin
								nightToggle <= !nightToggle;
								dayToggle <= !dayToggle;
							end
						end
			playingNight: begin
						if(countTime >= 49_999_990)
							begin
								cloud1X <= cloud1X + 3'd2;
								cloud2X <= cloud2X + 1'd1;
								cloud3X <= cloud3X + 1'd1;
							end
						if(countDayNight >= 20)
							begin
								nightToggle <= !nightToggle;
								dayToggle <= !dayToggle;
							end
						end		
		endcase
	end

/***********************************************************************************************************************/	

// States, parameters and transitions

/***********************************************************************************************************************/

	reg [1:0] s;
	reg [1:0] ns;

	parameter 
		menu = 2'd0,
		lose = 2'd1,
		playingDay = 2'd2,
		playingNight = 2'd3;

always@(posedge CLK or negedge RST_BTN)
begin
	if (RST_BTN == 1'b0)
		begin
			s <= menu;
		end
	else
		begin
			s <= ns;
		end
end

// state transition
always@(*)
begin
	case(s)
		menu: begin
				if(KEY0 == 1'b0)
				begin
					ns = playingDay;
					//enable = 1'b1;
				end
				else
					ns = menu;
				end
		playingDay: begin
				if(hit == 1'b1)
					ns = lose;
				else if(nightToggle)
					ns = playingNight;
				else
					ns = playingDay;
				end
		playingNight: begin
				if(hit == 1'b1)
					ns = lose;
				else if(dayToggle)
					ns = playingDay;
				else
					ns = playingNight;
				end
		lose: begin
				if(KEY1 == 1'b0)
					ns = menu;
				else
					ns = lose;
				end
	endcase
end
		

/***********************************************************************************************************************/

//Counter for score, iterates up 1 every second survived

/***********************************************************************************************************************/

// displays scores
sevenSeg ones(oneOut[3], oneOut[2], oneOut[1], oneOut[0], a, ba, c, d, e, f, g);
sevenSeg tens(tenOut[3], tenOut[2], tenOut[1], tenOut[0], a1, ba1, c1, d1, e1, f1, g1);
sevenSeg hunds(hunOut[3], hunOut[2], hunOut[1], hunOut[0], a2, ba2, c2, d2, e2, f2, g2);
sevenSeg thous(thoOut[3], thoOut[2], thoOut[1], thoOut[0], a3, ba3, c3, d3, e3, f3, g3);

reg[3:0] oneCount, oneHi, oneOut;
reg[3:0] tenCount, tenHi, tenOut;
reg[3:0] hunCount, hunHi, hunOut;
reg[3:0] thoCount, thoHi, thoOut;

always@(posedge CLK)
	begin
		if(RST_BTN == 1'b0)
			begin
				oneHi <= 4'd0;
				tenHi <= 4'd0;
				hunHi <= 4'd0;
				thoHi <= 4'd0;
			end
		if(SW0 == 1'b1)
			begin
				oneOut <= oneHi;
				tenOut <= tenHi;
				hunOut <= hunHi;
				thoOut <= thoHi;
			end
		else
			begin
				oneOut <= oneCount;
				tenOut <= tenCount;
				hunOut <= hunCount;
				thoOut <= thoCount;
			end
		case(s)
			menu: begin
					oneCount <= 4'd0;
					tenCount <= 4'd0;
					hunCount <= 4'd0;
					thoCount <= 4'd0;
					end
			playingDay: begin
						if(countTime >= 50_000_000)
							begin
								oneCount <= oneCount + 1'd1;
								if(oneCount >= 4'd9)
									begin
										tenCount <= tenCount + 1'd1;
										oneCount <= 1'd0;
									end
								if(tenCount > 4'd9)
									begin
										hunCount <= hunCount + 1'd1;
										tenCount <= 1'd0;
									end
								if(hunCount > 4'd9)
									begin
										thoCount <= thoCount + 1'd1;
										hunCount <= 1'd0;
									end
							end
						end
				playingNight: begin
						if(countTime >= 50_000_000)
							begin
								oneCount <= oneCount + 1'd1;
								if(oneCount >= 4'd9)
									begin
										tenCount <= tenCount + 1'd1;
										oneCount <= 1'd0;
									end
								if(tenCount >= 4'd9)
									begin
										hunCount <= hunCount + 1'd1;
										tenCount <= 1'd0;
									end
								if(hunCount >= 4'd9)
									begin
										thoCount <= thoCount + 1'd1;
										hunCount <= 1'd0;
									end
							end
						end
				// Update highscore
				lose: begin
						if(thoCount > thoHi)
							begin
								oneHi <= oneCount;
								tenHi <= tenCount;
								hunHi <= hunCount;
								thoHi <= thoCount;
							end
						else if(thoCount == thoHi)
							begin
								if(hunCount > hunHi)
									begin
										oneHi <= oneCount;
										tenHi <= tenCount;
										hunHi <= hunCount;
										thoHi <= thoCount;
									end
								else if(hunCount == hunHi)
									begin
										if(tenCount > tenHi)
											begin
												oneHi <= oneCount;
												tenHi <= tenCount;
												hunHi <= hunCount;
												thoHi <= thoCount;
											end
										else if(tenCount == tenHi)
											begin
												if(oneCount > oneHi)
													begin
														oneHi <= oneCount;
														tenHi <= tenCount;
														hunHi <= hunCount;
														thoHi <= thoCount;
													end
											end
									end
							end
						end				
			endcase
	end
	
/***********************************************************************************************************************/

// vga output

/***********************************************************************************************************************/

wire bg = ~(backDrop || sun || blocks[0] || blocks[1] || blocks[2] || blocks[3] || dino || cloud || cloud2 || cloud3) && (x >= 1 && x <= 639 && y >= 1 && y <= 479);

always@(*)
	begin
		case(s)
			menu: begin
						VGA_R[3] = backDrop | sun;        
						VGA_G[3] = blocks[0] | blocks[1] | blocks[3] | blocks[2] | sun;  
						VGA_B[3] = dino | bg;         

						VGA_R[2] = backDrop | sun | cloud | cloud2 | cloud3 | bg;         
						VGA_G[2] = blocks[0] | blocks[1] | blocks[3] | blocks[2] | backDrop | sun | cloud | cloud2 | cloud3 | bg;  
						VGA_B[2] = cloud | cloud2 | cloud3 | dino;         

						VGA_R[1] = backDrop | sun | cloud | cloud2 | cloud3 | bg;         
						VGA_G[1] = backDrop | sun | cloud | cloud2 | cloud3 | bg;  
						VGA_B[1] = backDrop | cloud | cloud2 | cloud3 | dino;         

						VGA_R[0] = backDrop | cloud | cloud2 | cloud3;         
						VGA_G[0] = cloud | cloud2 | cloud3;  
						VGA_B[0] = cloud | cloud2 | cloud3 | dino | bg;         
					end

			playingDay: begin
						VGA_R[3] = backDrop | sun;         
						VGA_G[3] = blocks[0] | blocks[1] | blocks[3] | blocks[2] | sun;  
						VGA_B[3] = dino | bg;         

						VGA_R[2] = backDrop | sun | cloud | cloud2 | cloud3 | bg;         
						VGA_G[2] = backDrop | blocks[0] | blocks[1] | blocks[3] | blocks[2] | sun | cloud | cloud2 | cloud3 | bg;  
						VGA_B[2] = dino | cloud | cloud2 | cloud3;         

						VGA_R[1] = backDrop | sun | cloud | cloud2 | cloud3 | bg;         
						VGA_G[1] = backDrop | sun | cloud | cloud2 | cloud3 | bg; 
						VGA_B[1] = backDrop | dino | cloud | cloud2 | cloud3;         

						VGA_R[0] = backDrop | cloud | cloud2 | cloud3;         
						VGA_G[0] = cloud | cloud2 | cloud3;  
						VGA_B[0] = dino | cloud | cloud2 | cloud3 | bg;         

					end
					
			playingNight: begin
						VGA_R[3] = moon | star | star1 | star2 | star3 | star4 | star5 | star6 | star7 | star8 | star9;
						VGA_G[3] = moon | star | star1 | star2 | star3 | star4 | star5 | star6 | star7 | star8 | star9 | blocks[0] | blocks[1] | blocks[3] | blocks[2];  
						VGA_B[3] = dino | moon | star | star1 | star2 | star3 | star4 | star5 | star6 | star7 | star8 | star9;         

						VGA_R[2] = backDrop | moon | cloud | cloud2 | cloud3 |star | star1 | star2 | star3 | star4 | star5 | star6 | star7 | star8 | star9;         
						VGA_G[2] = backDrop | moon | cloud | cloud2 | cloud3 | star | star1 | star2 | star3 | star4 | star5 | star6 | star7 | star8 | star9 | blocks[0] | blocks[1] | blocks[3] | blocks[2];  
						VGA_B[2] = dino | cloud | cloud2 | cloud3 | moon | star | star1 | star2 | star3 | star4 | star5 | star6 | star7 | star8 | star9;         
						
						VGA_R[1] = backDrop | moon | cloud | cloud2 | cloud3 | star | star1 | star2 | star3 | star4 | star5 | star6 | star7 | star8 | star9;         
						VGA_G[1] = backDrop | moon | cloud | cloud2 | cloud3 | star | star1 | star2 | star3 | star4 | star5 | star6 | star7 | star8 | star9; 
						VGA_B[1] = backDrop | dino | cloud | cloud2 | cloud3 | moon | star | star1 | star2 | star3 | star4 | star5 | star6 | star7 | star8 | star9;         

						VGA_R[0] = backDrop | cloud | cloud2 | cloud3 | moon | star | star1 | star2 | star3 | star4 | star5 | star6 | star7 | star8 | star9;         
						VGA_G[0] = cloud | cloud2 | cloud3 | moon | star | star1 | star2 | star3 | star4 | star5 | star6 | star7 | star8 | star9;  
						VGA_B[0] = dino | cloud | cloud2 | cloud3 | moon | star | star1 | star2 | star3 | star4 | star5 | star6 | star7 | star8 | star9;         
						end

			lose: begin
						VGA_R[0] = backDrop;         
						VGA_G[0] = blocks[0] | blocks[1] | blocks[3] | blocks[2];  
						VGA_B[0] = 0;         

						VGA_R[1] = backDrop | o1left | o1right | o1bottom | o1top | o2left | o2right | o2top | o2bottom | fleft | ftop | fbottom;         
						VGA_G[1] = 0;  
						VGA_B[1] = 0;        

						VGA_R[2] = backDrop;         
						VGA_G[2] = 0; 
						VGA_B[2] = 0;         

						VGA_R[3] = backDrop | o1left | o1right | o1bottom | o1top | o2left | o2right | o2top | o2bottom | fleft | ftop | fbottom;         
						VGA_G[3] = 0;  
						VGA_B[3] = 0;         
					end
		endcase
end

/***********************************************************************************************************************/

// Dino Logic for jumping and crouching

/***********************************************************************************************************************/

wire dino;
reg[9:0] dinoX;
reg[8:0] dinoY;
reg[9:0] dinoWidth;
reg[8:0] dinoHeight;
reg[1:0] direction;
reg[7:0] speedD;
reg[19:0] count;
reg[7:0] count2;
reg st_count2;

/// Crouching ///

always@(posedge CLK)
	begin
		case(s)
		menu: begin
					dinoX = 75;
					dinoWidth = 15;
					dinoHeight = 40;			
				end
		playingDay: begin
			if(KEY2 == 1'b0) // crouch
				begin
					dinoX = 75;
					dinoWidth = 15;
					dinoHeight = 20;
					speedD = 2;
				end
			else 
				begin
					dinoX = 75;
					dinoWidth = 15;
					dinoHeight = 40;
					speedD = 2;
				end
			end
		playingNight: begin
			if(KEY2 == 1'b0) // crouch
				begin
					dinoX = 75;
					dinoWidth = 15;
					dinoHeight = 20;
					speedD = 2;
				end
			else 
				begin
					dinoX = 75;
					dinoWidth = 15;
					dinoHeight = 40;
					speedD = 2;
				end
			end
		endcase
	end

always@(posedge CLK)
	begin
		if(count == 20'd500_000)
			begin
				count <= 20'd0;
			end
		else
			begin
				count <= count + 20'd1;
			end

		if (st_count2 == 1'b1)
			begin
				if (count2 <= 8'd90)
					begin
						if (count == 20'd500_000)
							begin
								count2 <= count2 + 1'b1;
							end
					end
				else
					begin
						st_count2 <= 1'b0;
						count2 <= 8'd0;
					end
			end
		case(s)
			playingDay: begin
						if(KEY3 == 1'b0)
							begin
								st_count2 <= 1'b1;
							end
						else if(KEY2 == 1'b0 && st_count2 == 1'b1)
							begin
								count2 <= 8'd90;
							end
						end
			playingNight: begin
						if(KEY3 == 1'b0)
							begin
								st_count2 <= 1'b1;
							end
						else if(KEY2 == 1'b0 && st_count2 == 1'b1)
							begin
								count2 <= 8'd90;
							end
						end
		endcase
end

assign dino = ((x > dinoX) & (x < dinoWidth + dinoX) & (y > dinoY) & (y < dinoHeight + dinoY)) ? 1 : 0;

always@(posedge CLK)
	begin
		case(s)
			menu: begin
					dinoY = 260;
					direction = 2'd3;
					end
			playingDay: begin
					// dinoY  <= 260;
					if(count == 20'd500000) // jumping
						begin
							if(direction == 2'b1)
								begin
									dinoY <= dinoY - speedD;
								end
							else if(direction == 2'd2)
								begin
									dinoY <= dinoY + speedD;
								end
							else if (direction == 2'd3)
								begin
									dinoY <= dinoY;
								end

							if(count2 > 8'd0 && count2 <= 8'd45)
								begin
									direction <= 2'b1;
								end
							else if(count2 >= 8'd45 && count2 <= 8'd90)
								begin
									direction <= 2'd2;
								end
							else if(count2 == 8'd0)
								begin
									direction <= 2'd3;
								end
							end
							else if(KEY2 == 1'b0  && (count2 >= 90 || count2 == 0)) // crouching
								begin
									dinoY <= 280;
								end
							else if(count2 >= 90 || count2 == 0)
								begin
									dinoY <= 260;
								end
						end
			playingNight: begin
					if(count == 20'd500000) // jumping
						begin
							if(direction == 2'b1)
								begin
									dinoY <= dinoY - speedD;
								end
							else if(direction == 2'd2)
								begin
									dinoY <= dinoY + speedD;
								end
							else if (direction == 2'd3)
								begin
									dinoY <= dinoY;
								end

							if(count2 > 8'd0 && count2 <= 8'd45)
								begin
									direction <= 2'b1;

								end
							else if(count2 >= 8'd45 && count2 <= 8'd90)
								begin
									direction <= 2'd2;

								end
							else if(count2 == 8'd0)
								begin
									direction <= 2'd3;
								end
							end
							else if(KEY2 == 1'b0  && (count2 >= 90 || count2 == 0))
								begin
									dinoY <= 280;
								end
							else if(count2 >= 90 || count2 == 0)
								begin
									dinoY <= 260;
								end
					end
		endcase
end

/***********************************************************************************************************************/

//Cactus Logic & Main Game Counters

/***********************************************************************************************************************/
	randomBlock randGen(CLK, rstRand, rstSeed, seed, ranHeight, ranWidth, ranY);
	reg rstRand;
	wire[3:0] blocks;
	reg[9:0] b1X, b2X, b3X, b4X;
	reg[8:0] b1Y, b2Y, b3Y, b4Y;
	wire[8:0] ranY;
	reg[9:0] b1Width, b2Width, b3Width, b4Width;
	wire[8:0] ranWidth;
	reg[8:0] b1Height, b2Height, b3Height, b4Height;
	wire[8:0] ranHeight;
	reg[7:0] speedB;
	reg[19:0] countB1, countB2;
//Game Counter
	reg[25:0] countTime;
	reg[5:0] countTime2, countDayNight;

	assign blocks[0] = ((x > b1X) & (x < b1Width + b1X) & (y > b1Y) & (y < b1Height + b1Y)) ? 1 : 0;
	assign blocks[1] = ((x > b2X) & (x < b2Width + b2X) & (y > b2Y) & (y < b2Height + b2Y)) ? 1 : 0;
	assign blocks[2] = ((x > b3X) & (x < b3Width + b3X) & (y > b3Y) & (y < b3Height + b3Y)) ? 1 : 0;
	assign blocks[3] = ((x > b4X) & (x < b4Width + b4X) & (y > b4Y) & (y < b4Height + b4Y)) ? 1 : 0;

always@(posedge CLK) 
	begin
		case(s)
			menu: begin
				b1Width <= 20;
				b2Width <= 20;
				b3Width <= 20;
				b4Width <= 25;
				b1Height <= 20;
				b2Height <= 40;
				b3Height <= 30;
				b4Height <= 10;
				b1Y <= 280;
				b2Y <= 260;
				b3Y <= 270;
				b4Y <= 260;
				b1X <= 10;
				b2X <= 690;
				b3X <= 460;
				b4X <= 230;
				speedB <= 1;
				countTime2 <= 1'd0;
				countDayNight <= 1'd0;
				rstRand <= 1'b0;
				end
			playingDay:
				begin
					rstRand <= 1'b1;				
					if(blocks[0] == 1'b1 && (b1X < 1 || b2X > 679))
						begin
							b2Width <= ranWidth;
							b2Height <= ranHeight;
							b2Y <= ranY;
						end
					if(blocks[1] == 1'b1 && (b2X < 1 || b2X > 679))
						begin
							b3Width <= ranWidth;
							b3Height <= ranHeight;
							b3Y <= ranY;
						end
					if(blocks[2] == 1'b1 && (b3X < 1 || b3X > 679))
						begin
							b4Width <= ranWidth;
							b4Height <= ranHeight;
							b4Y <= ranY;
						end
					if(blocks[3] == 1'b1 && (b4X < 1 || b4X > 679))
						begin
							b1Width <= ranWidth;
							b1Height <= ranHeight;
							b1Y <= ranY;
						end
					countTime <= countTime + 1'd1;
					countB1 <= countB1 + 1'd1;
					if(countB1 == 20'd500_000)
						begin
							b1X <= b1X - speedB;
							b2X <= b2X - speedB;
							b3X <= b3X - speedB;
							b4X <= b4X - speedB;
							countB1 <= 20'd0;
						end
					// Counts exactly one second based on the 50 mHz clock, reused in other parts of code
					if(countTime >= 50_000_000)
						begin
							countTime <= 0;
							countTime2 <= countTime2 + 1'd1;
							countDayNight <= countDayNight + 1'd1;
						end
					if(countTime2 >= 5'd30 && speedB <= 5'd3)
						begin
							speedB <= speedB + 1'd1;
							countTime2 <= 1'd0;
						end
					if(countDayNight >= 5'd20)
						begin
							countDayNight <= 5'd0;
						end
				end
			playingNight:
				begin
					rstRand <= 1'b1;
					if(blocks[0] == 1'b1 && (b1X < 1 || b2X > 679))
						begin
							b1Width <= ranWidth;
							b1Height <= ranHeight;
							b1Y <= ranY;
						end
					if(blocks[1] == 1'b1 && (b2X < 1 || b2X > 679))
						begin
							b2Width <= ranWidth;
							b2Height <= ranHeight;
							b2Y <= ranY;
						end
					if(blocks[2] == 1'b1 && (b3X < 1 || b3X > 679))
						begin
							b3Width <= ranWidth;
							b3Height <= ranHeight;
							b3Y <= ranY;
						end
					if(blocks[3] == 1'b1 && (b4X < 1 || b4X > 679))
						begin
							b4Width <= ranWidth;
							b4Height <= ranHeight;
							b4Y <= ranY;
						end
					countTime <= countTime + 1'd1;
					countB1 <= countB1 + 1'd1;
					if(countB1 == 20'd500_000)
						begin
							b1X <= b1X - speedB;
							b2X <= b2X - speedB;
							b3X <= b3X - speedB;
							b4X <= b4X - speedB;
							countB1 <= 20'd0;
						end
					// Counts exactly one second based on the 50 mHz clock, reused in other parts of code
					if(countTime >= 50_000_000)
						begin
							countTime <= 0;
							countTime2 <= countTime2 + 1'd1;
							countDayNight <= countDayNight + 1'd1;
						end
					if(countTime2 >= 5'd30 && speedB <= 5'd3)
						begin
							speedB <= speedB + 1'd1;
							countTime2 <= 1'd0;
						end
					if(countDayNight >= 5'd20)
						begin
							countDayNight <= 5'd0;
						end
				end
				
		endcase
	end
	
/***********************************************************************************************************************/

// Seed Generator for LFSR 
// Based on clock and key inputs from player

/***********************************************************************************************************************/

reg[2:0] seedCount, seed;
reg rstSeed;

always@(posedge CLK)
	begin
		case(s)
			menu: begin
					//enRand <= 1'b0;
					rstSeed <= 1'b1;
					seedCount <= 1'b0;
					end
			playingDay: begin
							//enRand <= 1'b1;
							rstSeed <= 1'b1;
							seedCount <= seedCount + 1'd1;
							if(seedCount >= 3'd8)
								begin
									seedCount <= 3'd0;
								end
							if(KEY3 == 1'b0 || KEY2 == 1'b0)
								begin
									rstSeed <= 1'b0;
									seed <= seedCount;
									//ranP <= ranOut;
								end
							end
			playingNight: begin
							//enRand <= 1'b1;
							rstSeed <= 1'b1;
							seedCount <= seedCount + 1'd1;
							if(seedCount >= 3'd8)
								begin
									seedCount <= 3'd0;
								end
							if(KEY3 == 1'b0 || KEY2 == 1'b0)
								begin
									rstSeed <= 1'b0;
									seed <= seedCount;
									//ranP <= ranOut;
								end
							end
		endcase
	end
/***********************************************************************************************************************/
	
// Collision Logic

/***********************************************************************************************************************/

wire hit;

assign hit = ((dino && blocks[0]) || (dino && blocks[1]) || (dino && blocks[3]) || (dino && blocks[2]));

endmodule

/***********************************************************************************************************************/

// Controls 7-segement to keep track of score

/***********************************************************************************************************************/

module sevenSeg(a, b, c, d, o1, o2, o3, o4, o5, o6, o7);
	input a, b, c, d; 
	output o1, o2, o3, o4, o5, o6, o7;
	
	assign o1 =~((~b&~d) | (~a&c) | (b&c) | (a&~d) | (~a&b&d) | (a&~b&~c));
	
	assign o2 =~((~a&~b) | (~b&~d) | (~a&~c&~d) | (~a&c&d) | (a&~c&d));
	
	assign o3 =~((~a&~c) | (~a&d) | (~c&d) | (~a&b) | (a&~b));
	
	assign o4 =~((~a&~b&~d) | (~b&c&d) | (b&~c&d) | (b&c&~d) | (a&~c&~d));
	
	assign o5 =~((~b&~d) | (c&~d) | (a&c) | (a&b));
	
	assign o6 =~((~c&~d) | (b&~d) | (a&~b) | (a&c) | (~a&b&~c));
	
	assign o7 =~((~b&c) | (c&~d) | (a&~b) | (a&d) | (~a&b&~c));
	
endmodule 

/***********************************************************************************************************************/

// Pseudo Random Number Generator (Linear Feedback Shift Register with Finite State Machine)

/***********************************************************************************************************************/

module linearFeedShiftReg(
input clk, rst, rstSeed,
input[2:0] seed,
output reg[2:0] out
);

always@(posedge clk)
	begin
		if(rst == 1'b0)
			out <= seed;
		else
			out <= {out[1]^out[2], out[2:0]};
	end
endmodule

module randomBlock(
input clk, rst, rstSeed,
input[2:0] seed,
output reg[5:0] height, width,
output reg[8:0] yVal
);
reg[2:0] S, NS;
wire[2:0] out;

linearFeedShiftReg regboi(clk, rstSeed, seed, out);

initial
	begin
	height = 6'd20;
	width = 6'd20;
	yVal = 9'd280;
	end

parameter
	blockT1 = 3'b000,
	blockT2 = 3'b001,
	blockT3 = 3'b010,
	blockT4 = 3'b011,
	blockT5 = 3'b100,
	blockT6 = 3'b101,
	blockT7 = 3'b110,
	blockT8 = 3'b111;
	
always@(posedge clk or negedge rst)
	begin
		if(rst == 1'b0)
			S <= blockT1;
		else
			S <= NS;
	end
	
always@(posedge clk)
	begin
		case(S)
			blockT1: begin
						height <= 6'd20;
						width <= 6'd20;
						yVal <= 9'd280;
						NS <= blockT2;
						end
			blockT2: begin
						height <= 6'd40;
						width <= 6'd15;
						yVal <= 9'd260;
						NS <= blockT3;
						end
			blockT3: begin
						height <= 6'd30;
						width <= 6'd10;
						yVal <= 9'd270;
						NS <= blockT4;
						end
			blockT4:	begin
						height <= 6'd40;
						width <= 6'd20;
						yVal <= 9'd260;
						NS <= blockT5;
						end
			blockT5: begin
						height <= 6'd35;
						width <= 6'd20;
						yVal <= 9'd265;
						NS <= blockT6;
						end
			blockT6: begin
						height <= 6'd10;
						width <= 6'd25;
						yVal <= 9'd270;
						NS <= blockT7;
						end
			blockT7: begin
						height <= 6'd10;
						width <= 6'd25;
						yVal <= 9'd280;
						NS <= blockT8;
						end
			blockT8: begin
						height <= 6'd10;
						width <= 6'd25;
						yVal <= 9'd260;
						NS <= blockT1;
						end
			default: NS <= out;
		endcase
	end
endmodule
