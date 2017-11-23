----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:00:12 10/07/2016 
-- Design Name: 
-- Module Name:    lab2 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; --use CONV_INTEGER
use work.rc5_pkg.All;



entity encrypt is
PORT (
		clr: IN STD_LOGIC;  -- asynchronous reset
  clk: IN STD_LOGIC;  -- Clock signal
  din: IN STD_LOGIC_VECTOR(63 DOWNTO 0);--64-bit i/p
  dout: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);--64-bit o/p
 di_vld: IN	STD_LOGIC;
 do_rdy: OUT	STD_LOGIC:= '0';
 skey : IN S_ARRAY
 
 );
end encrypt;




architecture simple of encrypt is
signal done: STD_LOGIC:= '0';

  --round counter
  SIGNAL i_cnt: STD_LOGIC_VECTOR(3 DOWNTO 0);  
  SIGNAL ab_xor: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL a_rot: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL a: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL a_pre	: STD_LOGIC_VECTOR(31 DOWNTO 0);

  --register to store value A
  SIGNAL a_reg: STD_LOGIC_VECTOR(31 DOWNTO 0); 
  SIGNAL ba_xor: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL b_rot: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL b: STD_LOGIC_VECTOR(31 DOWNTO 0);
  --register to store value B
  SIGNAL b_pre	: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL b_reg: STD_LOGIC_VECTOR(31 DOWNTO 0); 





TYPE  StateType IS (ST_IDLE, 
ST_PRE_ROUND, -- RC5 pre-round op is performed 
ST_ROUND_OP, -- RC5 round op is performed. The system remains in this state for twelve clock cycles.
ST_READY  
                                  );
SIGNAL  state   :   StateType;


BEGIN 


--------------registar A
    PROCESS(clr, clk)  BEGIN
        IF(clr='0') THEN
           a_reg<=(OTHERS=>'0');
        ELSIF(clk'EVENT AND clk='1') THEN
            IF(state=ST_PRE_ROUND) THEN   a_reg<=a_pre;
           ELSIF(state=ST_ROUND_OP) THEN   a_reg<=a;   END IF;
        END IF;
    END PROCESS;
    




-------------------------Registar B
    PROCESS(clr, clk)  BEGIN
        IF(clr='0') THEN
           b_reg<=(OTHERS=>'0');
        ELSIF(clk'EVENT AND clk='1') THEN
           IF(state=ST_PRE_ROUND) THEN   b_reg<=b_pre;
          ELSIF(state=ST_ROUND_OP) THEN   b_reg<=b;   END IF;
        END IF;
    END PROCESS;   
   -------------------------------state machine
   PROCESS(clr, clk)
   BEGIN
      IF(clr='0') THEN
         state<=ST_IDLE;
      
		ELSIF(clk'EVENT AND clk='1') THEN
         CASE state IS
            WHEN ST_IDLE=>  
					IF(di_vld = '1' and done = '0') THEN 
					state<=ST_PRE_ROUND;  
					END IF;
					
            WHEN ST_PRE_ROUND=>    state<=ST_ROUND_OP;
            WHEN ST_ROUND_OP=>  
					IF(i_cnt="1100") THEN 
					state<=ST_READY;  
							END IF;
            WHEN ST_READY=>   
				
				
				state<=ST_IDLE;
         END CASE;
      END IF;
   END PROCESS;



PROCESS(clr, clk)  
BEGIN
  IF(clr='0') THEN 
	i_cnt<="0001";
  ELSIF(clk'EVENT AND clk='1') THEN
  IF(state=ST_ROUND_OP) THEN

       IF(i_cnt="1100") THEN
         i_cnt<="0001";
       ELSE
         i_cnt<=i_cnt+'1';
       END IF;
		 End IF;
    END IF;
END PROCESS;




ab_xor <= a_reg XOR b_reg;


    WITH   b_reg(4 DOWNTO 0) SELECT
	 	 a_rot <=	
	 ab_xor(30 DOWNTO 0) & ab_xor(31) WHEN "00001",
	 ab_xor(29 DOWNTO 0) & ab_xor(31 DOWNTO 30) WHEN "00010",
	 ab_xor(28 DOWNTO 0) & ab_xor(31 DOWNTO 29) WHEN "00011",
	ab_xor(27 DOWNTO 0) & ab_xor(31 DOWNTO 28) WHEN "00100",
	ab_xor(26 DOWNTO 0) & ab_xor(31 DOWNTO 27) WHEN "00101",
	ab_xor(25 DOWNTO 0) & ab_xor(31 DOWNTO 26) WHEN "00110",
	ab_xor(24 DOWNTO 0) & ab_xor(31 DOWNTO 25) WHEN "00111",
	ab_xor(23 DOWNTO 0) & ab_xor(31 DOWNTO 24) WHEN "01000",
	ab_xor(22 DOWNTO 0) & ab_xor(31 DOWNTO 23) WHEN "01001",
	ab_xor(21 DOWNTO 0) & ab_xor(31 DOWNTO 22) WHEN "01010",
	ab_xor(20 DOWNTO 0) & ab_xor(31 DOWNTO 21) WHEN "01011",
	ab_xor(19 DOWNTO 0) & ab_xor(31 DOWNTO 20) WHEN "01100",
	ab_xor(18 DOWNTO 0) & ab_xor(31 DOWNTO 19) WHEN "01101",
	ab_xor(17 DOWNTO 0) & ab_xor(31 DOWNTO 18) WHEN "01110",
	ab_xor(16 DOWNTO 0) & ab_xor(31 DOWNTO 17) WHEN "01111",
	ab_xor(15 DOWNTO 0) & ab_xor(31 DOWNTO 16) WHEN "10000",
	ab_xor(14 DOWNTO 0) & ab_xor(31 DOWNTO 15) WHEN "10001",
	ab_xor(13 DOWNTO 0) & ab_xor(31 DOWNTO 14) WHEN "10010",
	ab_xor(12 DOWNTO 0) & ab_xor(31 DOWNTO 13) WHEN "10011",
	ab_xor(11 DOWNTO 0) & ab_xor(31 DOWNTO 12) WHEN "10100",
	ab_xor(10 DOWNTO 0) & ab_xor(31 DOWNTO 11) WHEN "10101",
	ab_xor(9 DOWNTO 0) & ab_xor(31 DOWNTO 10) WHEN "10110",
	ab_xor(8 DOWNTO 0) & ab_xor(31 DOWNTO 9) WHEN "10111",
	ab_xor(7 DOWNTO 0) & ab_xor(31 DOWNTO 8) WHEN "11000",
	ab_xor(6 DOWNTO 0) & ab_xor(31 DOWNTO 7) WHEN "11001",
	ab_xor(5 DOWNTO 0) & ab_xor(31 DOWNTO 6) WHEN "11010",
	ab_xor(4 DOWNTO 0) & ab_xor(31 DOWNTO 5) WHEN "11011",
	ab_xor(3 DOWNTO 0) & ab_xor(31 DOWNTO 4) WHEN "11100",
	ab_xor(2 DOWNTO 0) & ab_xor(31 DOWNTO 3) WHEN "11101",
	ab_xor(1 DOWNTO 0) & ab_xor(31 DOWNTO 2) WHEN "11110",
	ab_xor(0) & ab_xor(31 DOWNTO 1) WHEN "11111",
	ab_xor WHEN OTHERS;
	
a_pre<=din(63 DOWNTO 32) + skey(0); 
a <= a_rot + skey(CONV_INTEGER(i_cnt & '0'));



ba_xor <= a XOR b_reg;


    WITH   a(4 DOWNTO 0) SELECT
	 	 b_rot<=	
	 ba_xor(30 DOWNTO 0) & ba_xor(31) WHEN "00001",
	 ba_xor(29 DOWNTO 0) & ba_xor(31 DOWNTO 30) WHEN "00010",
	 ba_xor(28 DOWNTO 0) & ba_xor(31 DOWNTO 29) WHEN "00011",
	ba_xor(27 DOWNTO 0) & ba_xor(31 DOWNTO 28) WHEN "00100",
	ba_xor(26 DOWNTO 0) & ba_xor(31 DOWNTO 27) WHEN "00101",
	ba_xor(25 DOWNTO 0) & ba_xor(31 DOWNTO 26) WHEN "00110",
	ba_xor(24 DOWNTO 0) & ba_xor(31 DOWNTO 25) WHEN "00111",
	ba_xor(23 DOWNTO 0) & ba_xor(31 DOWNTO 24) WHEN "01000",
	ba_xor(22 DOWNTO 0) & ba_xor(31 DOWNTO 23) WHEN "01001",
	ba_xor(21 DOWNTO 0) & ba_xor(31 DOWNTO 22) WHEN "01010",
	ba_xor(20 DOWNTO 0) & ba_xor(31 DOWNTO 21) WHEN "01011",
	ba_xor(19 DOWNTO 0) & ba_xor(31 DOWNTO 20) WHEN "01100",
	ba_xor(18 DOWNTO 0) & ba_xor(31 DOWNTO 19) WHEN "01101",
	ba_xor(17 DOWNTO 0) & ba_xor(31 DOWNTO 18) WHEN "01110",
	ba_xor(16 DOWNTO 0) & ba_xor(31 DOWNTO 17) WHEN "01111",
	ba_xor(15 DOWNTO 0) & ba_xor(31 DOWNTO 16) WHEN "10000",
	ba_xor(14 DOWNTO 0) & ba_xor(31 DOWNTO 15) WHEN "10001",
	ba_xor(13 DOWNTO 0) & ba_xor(31 DOWNTO 14) WHEN "10010",
	ba_xor(12 DOWNTO 0) & ba_xor(31 DOWNTO 13) WHEN "10011",
	ba_xor(11 DOWNTO 0) & ba_xor(31 DOWNTO 12) WHEN "10100",
	ba_xor(10 DOWNTO 0) & ba_xor(31 DOWNTO 11) WHEN "10101",
	ba_xor(9 DOWNTO 0) & ba_xor(31 DOWNTO 10) WHEN "10110",
	ba_xor(8 DOWNTO 0) & ba_xor(31 DOWNTO 9) WHEN "10111",
	ba_xor(7 DOWNTO 0) & ba_xor(31 DOWNTO 8) WHEN "11000",
	ba_xor(6 DOWNTO 0) & ba_xor(31 DOWNTO 7) WHEN "11001",
	ba_xor(5 DOWNTO 0) & ba_xor(31 DOWNTO 6) WHEN "11010",
	ba_xor(4 DOWNTO 0) & ba_xor(31 DOWNTO 5) WHEN "11011",
	ba_xor(3 DOWNTO 0) & ba_xor(31 DOWNTO 4) WHEN "11100",
	ba_xor(2 DOWNTO 0) & ba_xor(31 DOWNTO 3) WHEN "11101",
	ba_xor(1 DOWNTO 0) & ba_xor(31 DOWNTO 2) WHEN "11110",
	ba_xor(0) & ba_xor(31 DOWNTO 1) WHEN "11111",
	ba_xor WHEN OTHERS;

b_pre <= din(31 DOWNTO 0) + skey(1);  -- B = B + S[1]

b <= b_rot + skey(CONV_INTEGER(i_cnt & '1'));

dout <= a_reg & b_reg;

WITH state SELECT
        do_rdy <=	'1'  WHEN ST_READY,
		'0' WHEN OTHERS;

WITH state SELECT
        done <=	'1'  WHEN ST_READY,
		'0' WHEN OTHERS;
		

		
end simple;



