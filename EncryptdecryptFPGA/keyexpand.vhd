----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:53:39 11/26/2016 
-- Design Name: 
-- Module Name:    keyexpand - Behavioral 
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
--library WORK;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use work.rc5_pkg.All;
 USE IEEE.STD_LOGIC_UNSIGNED.ALL;




entity keyexpand is

    port    (
        clr	: IN STD_LOGIC;
        clk	: IN STD_LOGIC;
		  key_in	: IN STD_LOGIC;
        skey	: out  S_ARRAY;
        key_rdy	: OUT STD_LOGIC;		 
		  ukey	: in STD_LOGIC_VECTOR(127 DOWNTO 0):= x"00000000000000000000000000000000";
	  	switch_pick: in std_logic_vector(4 downto 0)
		);

end keyexpand;

architecture Behavioral of keyexpand is



signal a_tmp1: std_logic_vector(31 downto 0); 	--:=  x"00000000"; 	
signal a_tmp2: std_logic_vector(31 downto 0);   --:=  x"00000000";
signal a_reg: std_logic_vector(31 downto 0);	--:=  x"00000000";

signal ab_tmp:std_logic_vector(31 downto 0);	--:=  x"00000000";

signal b_tmp1:std_logic_vector(31 downto 0);	--:=  x"00000000";
signal b_tmp2:std_logic_vector(31 downto 0);	--:=  x"00000000";
signal b_reg: std_logic_vector(31 downto 0);	--:=  x"00000000";


signal i_cnt:std_logic_vector(4 downto 0):= "00000"; -- default as 0,can counts up to 32 
signal j_cnt: std_logic_vector(3 downto 0):= "0000"; -- default 0 can count to 15
constant loop_count_max: std_logic_vector(9 downto 0):= "0001001101";  -- 77

signal looper: std_logic_vector(7 downto 0):= "00000000"; --default 0
--signal out_put_select:  std_logic_vector(3 downto 0) ;-- this is one hex value meaning 4 bits meaning 16 positions for fpga


signal s_arr_tmp : S_ARRAY;--:= --(X"b7e15163", X"5618cb1c", X"f45044d5",X"9287be8e", X"30bf3847", X"cef6b200",
--               X"6d2e2bb9", X"0b65a572", X"a99d1f2b",
--               X"47d498e4",X"e60c129d", X"84438c56",
--               X"227b060f", X"c0b27fc8", X"5ee9f981",
--               X"fd21733a", X"9b58ecf3", X"399066ac",
--               X"d7c7e065", X"75ff5a1e", X"1436d3d7",
--               X"b26e4d90", X"50a5c749",X"eedd4102",
--               X"8d14babb", X"2b4c3474");
----					
signal l_arr : L_ARRAY;



 TYPE     StateType IS (ST_IDLE, ST_KEY_IN, ST_KEY_EXP, ST_READY);
SIGNAL	state : StateType;

-------------------------display
constant VAL_MAX : std_logic_vector(3 downto 0) := "1001"; --9

type arr is array(0 to 22) of std_logic_vector(7 downto 0);
signal NAME: arr;

signal Val : std_logic_vector(3 downto 0):= "1000";
signal hexval: std_logic_vector(31 downto 0):= x"00000001";
--signal show_value : std_logic_vector(63 downto 0);
constant CNTR_MAX : std_logic_vector(23 downto 0) := x"030D40"; --100,000,000 = clk cycles per second
signal Cntr : std_logic_vector(26 downto 0) := (others => '0');
signal done:  std_logic:= '0';
--signal key_rdyx	: STD_LOGIC;



---------------------------------------------------------------------------------
begin


a_tmp1 <= s_arr_tmp(conv_integer(i_cnt)  )  + a_reg + b_reg; -- S + A + B

a_tmp2 <= a_tmp1(28 DOWNTO 0) & a_tmp1(31 DOWNTO 29); 

ab_tmp <= a_tmp2 + b_reg; -- New A + B

b_tmp1 <= l_arr( conv_integer(j_cnt) ) + ab_tmp;  -- L index plus new A + B


 ----------------------counts to 78
  PROCESS(clr, clk) BEGIN
    IF(clr='0') THEN  
		looper <=(OTHERS=>'0'); 
		
		
    ELSIF(clk'EVENT AND clk='1') THEN
       IF( state = ST_KEY_EXP ) THEN 
         IF(looper = "001001101") THEN--if 77 go to 0
				looper <= (OTHERS=>'0');
				
         ELSE   
				
					looper <= looper + 1;
         END IF;
       END IF;
    END IF;
 END PROCESS;
 
 
  ---------i  mod code
process(clr,clk)
begin
  
     IF(clr='0') THEN  
	 i_cnt <= "00000";
    ELSIF(rising_edge(clk)) THEN
	 
       IF(state = ST_KEY_EXP ) THEN
         IF(i_cnt = 25) THEN  
			i_cnt <= "00000";
         ELSE   
			
			i_cnt<= i_cnt+1;
         
			END IF;
		 END IF;
    END IF;
	 end process;
---------j mod code
	 process(clr,clk)
	 begin
    IF(clr='0') THEN  
	 j_cnt <= "0000";
    ELSIF(clk'EVENT AND clk='1') THEN
       IF( state = ST_KEY_EXP ) THEN
         IF(j_cnt = 3) THEN   
			j_cnt <= "0000";
         ELSE 
			j_cnt <= j_cnt + '1';
			
         END IF;
			
       END IF;
    END IF; 
 end process;

WITH   ab_tmp(4 DOWNTO 0) SELECT
	 	 b_tmp2 <=	
	 b_tmp1(30 DOWNTO 0) & b_tmp1(31) WHEN "00001",
	 b_tmp1(29 DOWNTO 0) & b_tmp1(31 DOWNTO 30) WHEN "00010",
	 b_tmp1(28 DOWNTO 0) & b_tmp1(31 DOWNTO 29) WHEN "00011",
	b_tmp1(27 DOWNTO 0) & b_tmp1(31 DOWNTO 28) WHEN "00100",
	b_tmp1(26 DOWNTO 0) & b_tmp1(31 DOWNTO 27) WHEN "00101",
	b_tmp1(25 DOWNTO 0) & b_tmp1(31 DOWNTO 26) WHEN "00110",
	b_tmp1(24 DOWNTO 0) & b_tmp1(31 DOWNTO 25) WHEN "00111",
	b_tmp1(23 DOWNTO 0) & b_tmp1(31 DOWNTO 24) WHEN "01000",
	b_tmp1(22 DOWNTO 0) & b_tmp1(31 DOWNTO 23) WHEN "01001",
	b_tmp1(21 DOWNTO 0) & b_tmp1(31 DOWNTO 22) WHEN "01010",
	b_tmp1(20 DOWNTO 0) & b_tmp1(31 DOWNTO 21) WHEN "01011",
	b_tmp1(19 DOWNTO 0) & b_tmp1(31 DOWNTO 20) WHEN "01100",
	b_tmp1(18 DOWNTO 0) & b_tmp1(31 DOWNTO 19) WHEN "01101",
	b_tmp1(17 DOWNTO 0) & b_tmp1(31 DOWNTO 18) WHEN "01110",
	b_tmp1(16 DOWNTO 0) & b_tmp1(31 DOWNTO 17) WHEN "01111",
	b_tmp1(15 DOWNTO 0) & b_tmp1(31 DOWNTO 16) WHEN "10000",
	b_tmp1(14 DOWNTO 0) & b_tmp1(31 DOWNTO 15) WHEN "10001",
	b_tmp1(13 DOWNTO 0) & b_tmp1(31 DOWNTO 14) WHEN "10010",
	b_tmp1(12 DOWNTO 0) & b_tmp1(31 DOWNTO 13) WHEN "10011",
	b_tmp1(11 DOWNTO 0) & b_tmp1(31 DOWNTO 12) WHEN "10100",
	b_tmp1(10 DOWNTO 0) & b_tmp1(31 DOWNTO 11) WHEN "10101",
	b_tmp1(9 DOWNTO 0) & b_tmp1(31 DOWNTO 10) WHEN "10110",
	b_tmp1(8 DOWNTO 0) & b_tmp1(31 DOWNTO 9) WHEN "10111",
	b_tmp1(7 DOWNTO 0) & b_tmp1(31 DOWNTO 8) WHEN "11000",
	b_tmp1(6 DOWNTO 0) & b_tmp1(31 DOWNTO 7) WHEN "11001",
	b_tmp1(5 DOWNTO 0) & b_tmp1(31 DOWNTO 6) WHEN "11010",
	b_tmp1(4 DOWNTO 0) & b_tmp1(31 DOWNTO 5) WHEN "11011",
	b_tmp1(3 DOWNTO 0) & b_tmp1(31 DOWNTO 4) WHEN "11100",
	b_tmp1(2 DOWNTO 0) & b_tmp1(31 DOWNTO 3) WHEN "11101",
	b_tmp1(1 DOWNTO 0) & b_tmp1(31 DOWNTO 2) WHEN "11110",
	b_tmp1(0) & b_tmp1(31 DOWNTO 1) WHEN "11111",
	b_tmp1 WHEN OTHERS;
  
------------------------------------------------------------------------ line 3, this set initial S array

	
 PROCESS(clr, clk)
 BEGIN
   IF(clr='0') THEN	 -- After system reset, S array is initialized with P and Q
      s_arr_tmp(0)<=  "10110111111000010101000101100011"; --Pw
      s_arr_tmp(1)<=  "01010110000110001100101100011100"; --Pw+ Qw
      s_arr_tmp(2)<=  "11110100010100000100010011010101"; --Pw+ 2Qw
		s_arr_tmp(3)<=  x"9287be8e";
		s_arr_tmp(4)<=  x"30bf3847";
		s_arr_tmp(5)<=  x"cef6b200";
		s_arr_tmp(6)<=  x"6d2e2bb9";
		s_arr_tmp(7)<=  x"0b65a572";
		s_arr_tmp(8)<=  x"a99d1f2b";
		s_arr_tmp(9)<=  x"47d498e4";
		s_arr_tmp(10)<= X"e60c129d";
		s_arr_tmp(11)<=  X"84438c56";
		s_arr_tmp(12)<=  X"227b060f";
		s_arr_tmp(13)<=   X"c0b27fc8";
		s_arr_tmp(14)<=  X"5ee9f981";
		s_arr_tmp(15)<=   X"fd21733a";
		s_arr_tmp(16)<=   X"9b58ecf3";
		s_arr_tmp(17)<=  X"399066ac";
		s_arr_tmp(18)<=   X"d7c7e065";
		s_arr_tmp(19)<=  X"75ff5a1e";
		s_arr_tmp(20)<=  X"1436d3d7";
		s_arr_tmp(21)<=   X"b26e4d90";
		s_arr_tmp(22)<=  X"50a5c749";
		s_arr_tmp(23)<=  X"eedd4102";
		s_arr_tmp(24)<=   X"8d14babb";
		s_arr_tmp(25)<=  X"2b4c3474";
	ELSIF(clk'EVENT AND clk='1') THEN
     IF(state=ST_KEY_EXP) THEN  
	  s_arr_tmp(conv_integer(i_cnt))<=a_tmp2;
     END IF;
   END IF;
 END PROCESS;


		
		
		
------------------------------------------------------------------------------- line loop L array initilize

   PROCESS(clr, clk)
   BEGIN
     IF(clr='0') THEN
	  FOR i IN 0 TO 3 LOOP
           l_arr(i)<=(OTHERS=>'0');
        END LOOP;

     ELSIF(clk'EVENT AND clk='1') THEN
        
		  IF(state=ST_KEY_IN) THEN
           l_arr(0)<=ukey(31 DOWNTO 0);
          l_arr(1)<=ukey(63 DOWNTO 32);
          l_arr(2)<=ukey(95 DOWNTO 64);
          l_arr(3)<=ukey(127 DOWNTO 96);
			 
        ELSIF(state=ST_KEY_EXP) THEN
           l_arr( conv_integer(j_cnt)) <= b_tmp2;
        END IF;
     END IF;
  END PROCESS;

 

 --------------------------------------------------------------------------------------------------- state machine
  PROCESS(clr, clk)	
     BEGIN
       IF(clr='0') THEN
           state<=ST_IDLE;
       ELSIF(clk'EVENT AND clk='1') THEN
           CASE state IS
              WHEN ST_IDLE =>
                  	IF(key_in='1') THEN  
							state <= ST_KEY_IN;  
							END IF;
              WHEN ST_KEY_IN=> 
						
						state 	<=   ST_KEY_EXP;  
				  WHEN ST_KEY_EXP=> 
				  
						IF(  looper = loop_count_max ) THEN --if looper is 77 looper next value is 0   
						state <= ST_READY; 
						

						end if;
					when ST_READY=>
						IF(key_in = '0') THEN 
						state<=ST_IDLE;
						END IF;
						
          END CASE;
        END IF;
  END PROCESS;

------------------------------------------------------------------------------- registers

    -- A register
    PROCESS(clr, clk)  BEGIN
        IF(clr='0') THEN
           a_reg <= (OTHERS=>'0');
        ELSIF(clk'EVENT AND clk='1') THEN
           IF(state=ST_KEY_EXP) THEN   
			  a_reg <= a_tmp2;
           END IF;
        END IF;
    END PROCESS;

    -- B register
    PROCESS(clr, clk)  BEGIN
        IF(clr='0') THEN
           b_reg<=(OTHERS=>'0');
        ELSIF(clk'EVENT AND clk='1') THEN
           IF(state=ST_KEY_EXP) THEN   
			  b_reg <= b_tmp2;
           END IF;
        END IF;
    END PROCESS;   


--with out_put_select select
--
--skey(1 downto 0) <= s_arr_tmp(1 downto 0) when  x"0",
--skey(3 downto 2) <= s_arr_tmp(3 downto 2) when  x"1",
--skey(5 downto 4) <= s_arr_tmp(5 downto 4) when  x"2",
--skey(7 downto 6) <= s_arr_tmp(7 downto 6) when  x"3",
--skey(9 downto 8) <= s_arr_tmp(9 downto 8) when  x"4",
--skey(11 downto 10) <= s_arr_tmp(11 downto 10) when  x"5",
--skey(13 down to 12) <= s_arr_tmp(13 downto 12) when x"6",
--skey(15 down to 14) <= s_arr_tmp(15 downto 14) when x"7",
--skey(17 down to 16) <= s_arr_tmp(17 downto 16) when x"8",
--skey(19 down to 18) <= s_arr_tmp(19 downto 18) when x"9",
--skey(21 down to 20) <= s_arr_tmp(21 downto 20) when x"A",
--skey(23 down to 22) <= s_arr_tmp(23 downto 22) when x"B",
--skey(25 down to 24) <= s_arr_tmp(25 downto 24) when others;




--end process;

PROCESS(clk,clr) BEGIN
	IF( state = ST_READY AND clr = '1') THEN
		skey <= s_arr_tmp;
		key_rdy <= '1';
	ELSE
		key_rdy <= '0';
	END IF;
 END PROCESS;






------------------------------------------------------------






--process(CLK,switch_display) --Last 2 switches control what value you see on the 7seg
--Begin
--
--		if rising_edge(clk) then
--			case switch_display is
--				when '1' => 
--				if(key_rdyx'EVENT and key_rdyx = '1' and done /= '1') then
--				done <= '1';
--				--show_value <= doutx(63 downto 0);
--				end if;
--	
--			when others => show_value <= show_value;
--			end case;
--	end if;
--	
--end process;
---------------------------------------------------------change hexval
--with switch_pick select
--	hexval <=   skey(0) when "00000",
--					skey(1) when "00001",
--					skey(2) when "00010",
--					skey(3) when "00011",
--					skey(4) when "00100",
--					skey(5) when "00101",
--					skey(6) when "00110",
--					skey(7) when "00111",
--					skey(8) when "01000",
--					skey(9) when "01001",
--					skey(10) when "01010",
--					skey(11) when "01011",
--					skey(12) when "01100",
--					skey(13) when "01101",
--					skey(14) when "01110",
--					skey(15) when "01111",
--					skey(16) when "10000",
--					skey(17) when "10001",
--					skey(18) when "10010",
--					skey(19) when "10011",
--					skey(20) when "10100",
--					skey(21) when "10101",
--					skey(22) when "10110",
--					skey(23) when "10111",
--					skey(24) when "11000",
--					skey(25) when others;
--					
--					
--					

--
--







end Behavioral;

