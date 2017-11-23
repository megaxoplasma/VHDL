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
use work.rc5_pkg.All;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; --use CONV_INTEGER

entity decrypt is
PORT (
	clr: IN STD_LOGIC;  -- asynchronous reset
  clk: IN STD_LOGIC;  -- Clock signal
  din: IN STD_LOGIC_VECTOR(63 DOWNTO 0);--64-bit i/p
  dout: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);--64-bit o/p
   di_vld: IN	STD_LOGIC;
 do_rdy: OUT	STD_LOGIC;
 skey: In S_ARRAY
 );
end decrypt;




architecture inverse of decrypt is
signal done :STD_LOGIC;

  --round counter
  SIGNAL i_cnt: STD_LOGIC_VECTOR(3 DOWNTO 0);  
  SIGNAL a_rot: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL a: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL a_end	: STD_LOGIC_VECTOR(31 DOWNTO 0);
  
  --register to store value A
  SIGNAL a_reg: STD_LOGIC_VECTOR(31 DOWNTO 0); 

  Signal b_sub_s: STD_LOGIC_VECTOR(31 DOWNTO 0);
   Signal a_sub_s: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL b_rot: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL b: STD_LOGIC_VECTOR(31 DOWNTO 0);
  --register to store value B
  signal b_end : STD_LOGIC_VECTOR(31 downto 0);
  SIGNAL b_reg: STD_LOGIC_VECTOR(31 DOWNTO 0); 





TYPE  StateType IS (ST_IDLE, 
ST_END_ROUND, -- RC5 END-round op is performed 
ST_ROUND_OP, -- RC5 round op is performed. The system remains in this state for twelve clock cycles.
ST_READY  
                                  );
SIGNAL  state   :   StateType;

BEGIN 


--------------------A reg
PROCESS(clr, clk)  BEGIN
  IF(clr='0') THEN
           a_reg<= din(63 DOWNTO 32);
  ELSIF(clk'EVENT AND clk='1') THEN 
  IF(state=ST_END_ROUND) THEN   
  a_reg<= a_end;
  ELSIF(state=ST_ROUND_OP) THEN   
  a_reg<=a;  
  END IF;
  
   
  END IF;
END PROCESS;
----------------------------B reg
PROCESS(clr, clk)  BEGIN
       IF(clr='0') THEN
           b_reg<=din(31 DOWNTO 0);
			  
        ELSIF(clk'EVENT AND clk='1') THEN 
		  IF(state=ST_END_ROUND) THEN  
		  b_reg <= b_end;
           ELSIF(state=ST_ROUND_OP) THEN   
			  b_reg<=b;   END IF;
		  
		  
		  
        END IF;
    END PROCESS;   



--------------------------------------------------------state
   PROCESS(clr, clk)
   BEGIN
      IF(clr='0') THEN
         state<=ST_IDLE;
      
		ELSIF(clk'EVENT AND clk='1') THEN
         CASE state IS
            WHEN ST_IDLE=>  
					IF(di_vld = '1') THEN 
					state<= ST_ROUND_OP;  
					END IF;
            WHEN ST_END_ROUND=>
					
				state<=ST_READY;
				
            WHEN ST_ROUND_OP=>  
				IF(i_cnt="0001") THEN 
				state<=ST_END_ROUND;  
			    END IF;
				 
            WHEN ST_READY=>   
			
         END CASE;
      END IF;
   END PROCESS;
	--------------------------------round count
	PROCESS(clr, clk)  
BEGIN
  IF(clr='0') THEN 
	i_cnt<="1100";
  ELSIF(clk'EVENT AND clk='1') THEN
   IF(state = ST_ROUND_OP) THEN
       IF(i_cnt="0001") THEN
         i_cnt<="1100";
       ELSE
         i_cnt<=i_cnt-'1';
			END IF;
       END IF;
    END IF;
END PROCESS;
------------------------------------------------------------
b_sub_s <= b_reg - skey(CONV_INTEGER(i_cnt & '1'));


    WITH   a_reg(4 DOWNTO 0) SELECT
	 	 b_rot<=	
	 b_sub_s(30 DOWNTO 0) & b_sub_s(31) WHEN "11111",
	 b_sub_s(29 DOWNTO 0) & b_sub_s(31 DOWNTO 30) WHEN "11110",
	 b_sub_s(28 DOWNTO 0) & b_sub_s(31 DOWNTO 29) WHEN "11101",
	b_sub_s(27 DOWNTO 0) & b_sub_s(31 DOWNTO 28) WHEN "11100",
	b_sub_s(26 DOWNTO 0) & b_sub_s(31 DOWNTO 27) WHEN "11011",
	b_sub_s(25 DOWNTO 0) & b_sub_s(31 DOWNTO 26) WHEN "11010",
	b_sub_s(24 DOWNTO 0) & b_sub_s(31 DOWNTO 25) WHEN "11001",
	b_sub_s(23 DOWNTO 0) & b_sub_s(31 DOWNTO 24) WHEN "11000",
	b_sub_s(22 DOWNTO 0) & b_sub_s(31 DOWNTO 23) WHEN "10111",
	b_sub_s(21 DOWNTO 0) & b_sub_s(31 DOWNTO 22) WHEN "10110",
	b_sub_s(20 DOWNTO 0) & b_sub_s(31 DOWNTO 21) WHEN "10101",
	b_sub_s(19 DOWNTO 0) & b_sub_s(31 DOWNTO 20) WHEN "10100",
	b_sub_s(18 DOWNTO 0) & b_sub_s(31 DOWNTO 19) WHEN "10011",
	b_sub_s(17 DOWNTO 0) & b_sub_s(31 DOWNTO 18) WHEN "10010",
	b_sub_s(16 DOWNTO 0) & b_sub_s(31 DOWNTO 17) WHEN "10001",
	b_sub_s(15 DOWNTO 0) & b_sub_s(31 DOWNTO 16) WHEN "10000",
	b_sub_s(14 DOWNTO 0) & b_sub_s(31 DOWNTO 15) WHEN "01111",
	b_sub_s(13 DOWNTO 0) & b_sub_s(31 DOWNTO 14) WHEN "01110",
	b_sub_s(12 DOWNTO 0) & b_sub_s(31 DOWNTO 13) WHEN "01101",
	b_sub_s(11 DOWNTO 0) & b_sub_s(31 DOWNTO 12) WHEN "01100",
	b_sub_s(10 DOWNTO 0) & b_sub_s(31 DOWNTO 11) WHEN "01011",
	b_sub_s(9 DOWNTO 0) & b_sub_s(31 DOWNTO 10) WHEN "01010",
	b_sub_s(8 DOWNTO 0) & b_sub_s(31 DOWNTO 9) WHEN "01001",
	b_sub_s(7 DOWNTO 0) & b_sub_s(31 DOWNTO 8) WHEN "01000",
	b_sub_s(6 DOWNTO 0) & b_sub_s(31 DOWNTO 7) WHEN "00111",
	b_sub_s(5 DOWNTO 0) & b_sub_s(31 DOWNTO 6) WHEN "00110",
	b_sub_s(4 DOWNTO 0) & b_sub_s(31 DOWNTO 5) WHEN "00101",
	b_sub_s(3 DOWNTO 0) & b_sub_s(31 DOWNTO 4) WHEN "00100",
	b_sub_s(2 DOWNTO 0) & b_sub_s(31 DOWNTO 3) WHEN "00011",
	b_sub_s(1 DOWNTO 0) & b_sub_s(31 DOWNTO 2) WHEN "00010",
	b_sub_s(0) & b_sub_s(31 DOWNTO 1) WHEN "00001",
	b_sub_s WHEN OTHERS;


b <= a_reg XOR b_rot; --B = A XOR Brotated




a_sub_s <= a_reg - skey(CONV_INTEGER(i_cnt & '0'));


    WITH   b(4 DOWNTO 0) SELECT
	 	 	 a_rot<=	
	 a_sub_s(30 DOWNTO 0) & a_sub_s(31) WHEN "11111",
	 a_sub_s(29 DOWNTO 0) & a_sub_s(31 DOWNTO 30) WHEN "11110",
	 a_sub_s(28 DOWNTO 0) & a_sub_s(31 DOWNTO 29) WHEN "11101",
	a_sub_s(27 DOWNTO 0) & a_sub_s(31 DOWNTO 28) WHEN "11100",
	a_sub_s(26 DOWNTO 0) & a_sub_s(31 DOWNTO 27) WHEN "11011",
	a_sub_s(25 DOWNTO 0) & a_sub_s(31 DOWNTO 26) WHEN "11010",
	a_sub_s(24 DOWNTO 0) & a_sub_s(31 DOWNTO 25) WHEN "11001",
	a_sub_s(23 DOWNTO 0) & a_sub_s(31 DOWNTO 24) WHEN "11000",
	a_sub_s(22 DOWNTO 0) & a_sub_s(31 DOWNTO 23) WHEN "10111",
	a_sub_s(21 DOWNTO 0) & a_sub_s(31 DOWNTO 22) WHEN "10110",
	a_sub_s(20 DOWNTO 0) & a_sub_s(31 DOWNTO 21) WHEN "10101",
	a_sub_s(19 DOWNTO 0) & a_sub_s(31 DOWNTO 20) WHEN "10100",
	a_sub_s(18 DOWNTO 0) & a_sub_s(31 DOWNTO 19) WHEN "10011",
	a_sub_s(17 DOWNTO 0) & a_sub_s(31 DOWNTO 18) WHEN "10010",
	a_sub_s(16 DOWNTO 0) & a_sub_s(31 DOWNTO 17) WHEN "10001",
	a_sub_s(15 DOWNTO 0) & a_sub_s(31 DOWNTO 16) WHEN "10000",
	a_sub_s(14 DOWNTO 0) & a_sub_s(31 DOWNTO 15) WHEN "01111",
	a_sub_s(13 DOWNTO 0) & a_sub_s(31 DOWNTO 14) WHEN "01110",
	a_sub_s(12 DOWNTO 0) & a_sub_s(31 DOWNTO 13) WHEN "01101",
	a_sub_s(11 DOWNTO 0) & a_sub_s(31 DOWNTO 12) WHEN "01100",
	a_sub_s(10 DOWNTO 0) & a_sub_s(31 DOWNTO 11) WHEN "01011",
	a_sub_s(9 DOWNTO 0) & a_sub_s(31 DOWNTO 10) WHEN "01010",
	a_sub_s(8 DOWNTO 0) & a_sub_s(31 DOWNTO 9) WHEN "01001",
	a_sub_s(7 DOWNTO 0) & a_sub_s(31 DOWNTO 8) WHEN "01000",
	a_sub_s(6 DOWNTO 0) & a_sub_s(31 DOWNTO 7) WHEN "00111",
	a_sub_s(5 DOWNTO 0) & a_sub_s(31 DOWNTO 6) WHEN "00110",
	a_sub_s(4 DOWNTO 0) & a_sub_s(31 DOWNTO 5) WHEN "00101",
	a_sub_s(3 DOWNTO 0) & a_sub_s(31 DOWNTO 4) WHEN "00100",
	a_sub_s(2 DOWNTO 0) & a_sub_s(31 DOWNTO 3) WHEN "00011",
	a_sub_s(1 DOWNTO 0) & a_sub_s(31 DOWNTO 2) WHEN "00010",
	a_sub_s(0) & a_sub_s(31 DOWNTO 1) WHEN "00001",
	a_sub_s WHEN OTHERS;

a <= a_rot XOR b;

dout <= a_reg & b_reg;

a_end <= a_reg - skey(0);
b_end <= b_reg - skey(1);

WITH state SELECT
        do_rdy <=	'1' WHEN ST_READY,
		'0' WHEN OTHERS;

end inverse;



