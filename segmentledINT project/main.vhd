library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

----------------------------------------------------------------------------
-- RGB LED intensity control Project 
----------------------------------------------------------------------------
-- Author:  Ying Zhu
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
--This module lets you control each RGB color using switches
-- When incre is up the value for that color increase, meaning more red and brighter red
-- When incre is down the value decrease, less red  

-- change_r/g/b controls whether or not you want to change that color, if change is down that color is frozen and will not change regardless of
--the incre signal.

--This simple RGB module lets you control and mix colors to get the one that you like, so you can save that value/color for future usage.																
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--The IEEE.std_logic_unsigned contains definitions that allow 
--std_logic_vector types to be used with the + operator to instantiate a 
--counter.
use IEEE.std_logic_unsigned.all;

entity SevenSeg_Demo is
    Port ( SW 			: in  STD_LOGIC_VECTOR (6 downto 0);
           BTN 			: in  STD_LOGIC_VECTOR (4 downto 0);
           CLK 			: in  STD_LOGIC;
           LED 			: out  STD_LOGIC_VECTOR (6 downto 0);
           SSEG_CA 		: out  STD_LOGIC_VECTOR (7 downto 0);
           SSEG_AN 		: out  STD_LOGIC_VECTOR (7 downto 0);
			
			  led_16g      : out STD_LOGIC;
			  led_17g      : out STD_LOGIC;
			  
			  led_16b     : out STD_LOGIC;
			  led_17b     : out std_logic;
			  
			  led_16r     : out STD_LOGIC;
			  led_17r     : out std_logic;

			  green_incre: in std_logic;
			  change : in std_logic;
				
			  blue_incre: in std_logic;
			  change_b : in std_logic;

			  red_incre: in std_logic;
			  change_r : in std_logic
			  );
end SevenSeg_Demo;

architecture Behavioral of SevenSeg_Demo is

component Hex2LED 
port (CLK: in STD_LOGIC; X: in STD_LOGIC_VECTOR (3 downto 0); Y: out STD_LOGIC_VECTOR (7 downto 0)); 
end component; 

type arr is array(0 to 22) of std_logic_vector(7 downto 0);
signal NAME: arr;

signal Count_divider : std_logic_vector(40 downto 0) := (others => '0');
signal Count_divider_g : std_logic_vector(70 downto 0) := (others => '0');
signal Count_divider_b : std_logic_vector(70 downto 0) := (others => '0');
signal Count_divider_r : std_logic_vector(70 downto 0) := (others => '0');

constant CNTR_MAX : std_logic_vector(23 downto 0) := x"030D40"; --100,000,000 = clk cycles per second
constant VAL_MAX : std_logic_vector(3 downto 0) := "1001"; --9

constant RESET_CNTR_MAX : std_logic_vector(17 downto 0) := "110000110101000000";-- 100,000,000 * 0.002 = 200,000 = clk cycles per 2 ms


--This is used to determine when the 7-segment display should be
--incremented
signal Cntr : std_logic_vector(26 downto 0) := (others => '0');

--This counter keeps track of which number is currently being displayed
--on the 7-segment.
signal Val : std_logic_vector(3 downto 0) := (others => '0');

--This is the signal that holds the hex value to be diplayed
signal hexval: std_logic_vector(7 downto 0):=x"00";
signal led_16gs : STD_LOGIC;
signal led_17gs : STD_LOGIC;

signal led_16bs : STD_LOGIC;
signal led_17bs : STD_LOGIC ;

signal led_16rs : STD_LOGIC;
signal led_17rs : STD_LOGIC;

signal contr_vect:  std_logic_vector(7 downto 0):= x"00";
signal contr_vect_b:  std_logic_vector(7 downto 0):= x"00";
signal contr_vect_r:  std_logic_vector(7 downto 0):= x"00";


signal max_count: STD_LOGIC_VECTOR(7 downto 0) := x"FF";
signal reset: std_logic_vector(7 downto 0):= x"00";


signal clk_cntr_reg : std_logic_vector (4 downto 0) := (others=>'0'); 


begin
max_count <= x"FF";
reset <= x"00";
----------------------------------------------------------
------                LED Control                  -------
----------------------------------------------------------

with BTN(4) select --btn4 IS BTNU
	LED <= SW 			when '0',
			 "0000000" when others;

---- This updates what value needs to sent to 7seg display bases on Switch status
process(CLK,SW(1 downto 0)) --Last 2 switches control what value you see on the 7seg
Begin
	if hexval >= max_count then -- btn0 is BTNC -- acts as reset for the hexval
			hexval<= reset;
			
	elsif rising_edge(clk) and hexval /= x"FF" then
				case SW(1 downto 0) is
				when "11" => 
				
				if (Count_divider > 5000) then
				hexval<= hexval+'1'; -- SW=11 will make hexval as counter ans show output... Its so fast that you only see top 4 digits updating... last 4 digits are changing but you will not be able to changing
				Count_divider <= Count_divider XOR Count_divider;
				else
				Count_divider <= Count_divider + 1;
				end if;

				
				
				when "10" => hexval<=x"AA";
				when "01" => hexval<=hexval; -- Making SW=10 will bring stop the counter display its value.
			
				when others => hexval<=x"BB";
			end case;
			
		end if;
		
	
	
end process;
--------------------------------------------------------------------------------green
process(green_incre,change)
begin
if rising_edge(clk)  and change = '1' then
				if (green_incre = '1' and contr_vect < x"FE" ) then 	
					if (Count_divider_g > 10000000) then
					contr_vect <= contr_vect+'1'; -- SW=11 will make hexval as counter ans show output... Its so fast that you only see top 4 digits updating... last 4 digits are changing but you will not be able to changing
					Count_divider_g <= Count_divider_g XOR Count_divider_g;
					else
					Count_divider_g <= Count_divider_g + 1;
					end if;
				elsif (green_incre = '0' and contr_vect > x"02" ) then 	
					if (Count_divider_g > 10000000) then
					contr_vect <= contr_vect-'1'; -- SW=11 will make hexval as counter ans show output... Its so fast that you only see top 4 digits updating... last 4 digits are changing but you will not be able to changing
					Count_divider_g <= Count_divider_g XOR Count_divider_g;
					else
					Count_divider_g <= Count_divider_g + 1;
					
					
					end if;
				elsif (green_incre = '0' and contr_vect = x"02" ) then
					contr_vect <= x"00";
				elsif (green_incre = '1' and contr_vect = x"00" ) then
					contr_vect <= x"03";
					
				elsif (green_incre = '0' and contr_vect = x"FF" ) then
					contr_vect <= x"FB";
				elsif (green_incre = '1' and contr_vect = x"FE" ) then
					contr_vect <= x"FF";
				else
				end if;
end if;

if SW(3) = '1' and change = '0' and change_r = '0' and change_b = '0' then

--contr_vect_b <= contr_vect_b XOR contr_vect_b;
--contr_vect_r <= contr_vect_r XOR contr_vect_r;

contr_vect <= contr_vect XOR contr_vect;





end if;

end process;
------------------------------------------------------------------------------------------blue

process(blue_incre,change_b)
begin
if rising_edge(clk)  and change_b = '1' then
				if (blue_incre = '1' and contr_vect_b < x"FE" ) then 	
					if (Count_divider_b > 10000000) then
					contr_vect_b <= contr_vect_b + '1'; 
					Count_divider_b <= Count_divider_b XOR Count_divider_b;
					else
					Count_divider_b <= Count_divider_b + 1;
					end if;
				elsif (blue_incre = '0' and contr_vect_b > x"02" ) then 	
					if (Count_divider_b > 10000000) then
					contr_vect_b <= contr_vect_b - '1'; 
					Count_divider_b <= Count_divider_b XOR Count_divider_b;
					else
					Count_divider_b <= Count_divider_b + 1;
					
					
					end if;
				elsif (blue_incre = '0' and contr_vect_b = x"02" ) then
					contr_vect_b <= x"00";
				elsif (blue_incre = '1' and contr_vect_b = x"00" ) then
					contr_vect_b <= x"03";
					
				elsif (blue_incre = '0' and contr_vect_b = x"FF" ) then
					contr_vect_b <= x"FB";
				elsif (blue_incre = '1' and contr_vect_b = x"FE" ) then
					contr_vect_b <= x"FF";
				else
				end if;


end if;

if SW(3) = '1' and change = '0' and change_r = '0' and change_b = '0' then

contr_vect_b <= contr_vect_b XOR contr_vect_b;
--contr_vect_r <= contr_vect_r XOR contr_vect_r;

--contr_vect <= contr_vect_b XOR contr_vect_b;


end if;

end process;
---------------------------------------------------------------------------red

process(red_incre,change_r)
begin
if rising_edge(clk)  and change_r = '1' then
				if (red_incre = '1' and contr_vect_r < x"FE" ) then 	
					if (Count_divider_r > 10000000) then
					contr_vect_r <= contr_vect_r + '1'; -- SW=11 will make hexval as counter ans show output... Its so fast that you only see top 4 digits updating... last 4 digits are changing but you will not be able to changing
					Count_divider_r <= Count_divider_r XOR Count_divider_r;
					else
					Count_divider_r <= Count_divider_r + 1;
					end if;
				elsif (red_incre = '0' and contr_vect_r > x"02" ) then 	
					if (Count_divider_r > 10000000) then
					contr_vect_r <= contr_vect_r - '1'; -- SW=11 will make hexval as counter ans show output... Its so fast that you only see top 4 digits updating... last 4 digits are changing but you will not be able to changing
					Count_divider_r <= Count_divider_r XOR Count_divider_r;
					else
					Count_divider_r <= Count_divider_r + 1;
					
					
					end if;
				elsif (red_incre = '0' and contr_vect_r = x"02" ) then
					contr_vect_r <= x"00";
				elsif (red_incre = '1' and contr_vect_r = x"00" ) then
					contr_vect_r <= x"03";
					
				elsif (red_incre = '0' and contr_vect_r = x"FF" ) then
					contr_vect_r <= x"FB";
				elsif (red_incre = '1' and contr_vect_r = x"FE" ) then
					contr_vect_r <= x"FF";
				else
				end if;


end if;

if SW(3) = '1' and change = '0' and change_r = '0' and change_b = '0' then

--contr_vect_b <= contr_vect_b XOR contr_vect_b;
contr_vect_r <= contr_vect_r XOR contr_vect_r;

--contr_vect <= contr_vect_b XOR contr_vect_b;

end if;

end process;


----------------------------------------------green cycler
process
begin

if   ((hexval < contr_vect) ) then
			led_16gs <= '1';
			led_17gs <= '1';
			
			else 
			led_16gs <= '0';
			led_17gs <= '0';
		end if;	
				
end process	;
-----------------------------------------------------------blue cycler

process
begin
if   ((hexval < contr_vect_b) ) then			
			led_16bs <= '1';
			led_17bs <= '1';
			
			else 
			led_16bs <= '0';
			led_17bs <= '0';

		end if;	
				
end process	;
---------------------------------------------------------red cycler
process
begin
if   ((hexval < contr_vect_r) ) then			
			led_16rs <= '1';
			led_17rs <= '1';
			
			else 
			led_16rs <= '0';
			led_17rs <= '0';

		end if;	
				
end process	;






--process
--begin
--
--if     hexval > (x"3FFFFFF") then
--			led_b1s <= '1';
--			else 
--			led_b1s <= '0';
--		end if;	
--				
--end process	;



led_16g <= led_16gs;
led_17g <= led_17gs;

led_16b <= led_16bs;
led_17b <= led_17bs;

led_16r <= led_16rs;
led_17r <= led_17rs;



----------------------------------------------------------
------           7-Seg Display Control             -------
----------------------------------------------------------
--Digits are incremented every second, and are blanked in
--response to button presses.

--This process controls the counter that triggers the 7-segment
--to be incremented. It counts 100,000,000 and then resets.		  
timer_counter_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if ((Cntr = CNTR_MAX) or (BTN(4) = '1')) then
			Cntr <= (others => '0');
		else
			Cntr <= Cntr + 1;
		end if;
	end if;
end process;

--This process increments the digit being displayed on the 
--7-segment display every second.
timer_inc_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if (BTN(4) = '1') then
			Val <= (others => '0');
		elsif (Cntr = CNTR_MAX) then
			if (Val = VAL_MAX) then
				Val <= (others => '0');
			else
				Val <= Val + 1;
			end if;
		end if;
	end if;
end process;

--This select statement selects the 7-segment diplay anode. 
with Val select
	SSEG_AN <= "01111111" when "0001",
				  "10111111" when "0010",
				  "11011111" when "0011",
				  "11101111" when "0100",
				  "11110111" when "0101",
				  "11111011" when "0110",
				  "11111101" when "0111",
				  "11111110" when "1000",
				  "11111111" when others;

--This select statement selects the value of HexVal to the necessary
--cathode signals to display it on the 7-segment
with Val select
	SSEG_CA <= NAME(0) when "0001",
				  NAME(1) when "0010",
				  NAME(2)when "0011",
				  NAME(3) when "0100",
				  NAME(4) when "0101",
				  NAME(5) when "0110",
				  NAME(6) when "0111",
				  NAME(7) when "1000",
				  NAME(0) when others;


CONV1: Hex2LED port map (CLK => CLK, X => contr_vect_r(7 downto 4), Y => NAME(0));
CONV2: Hex2LED port map (CLK => CLK, X => contr_vect_r(3 downto 0), Y => NAME(1));
--CONV3: Hex2LED port map (CLK => CLK, X => HexVal(23 downto 20), Y => NAME(2));
CONV4: Hex2LED port map (CLK => CLK, X => contr_vect_b(7 downto 4), Y => NAME(3));		
CONV5: Hex2LED port map (CLK => CLK, X => contr_vect_b(3 downto 0), Y => NAME(4));
--CONV6: Hex2LED port map (CLK => CLK, X => HexVal(11 downto 8), Y => NAME(5));
CONV7: Hex2LED port map (CLK => CLK, X => contr_vect(7 downto 4), Y => NAME(6));
CONV8: Hex2LED port map (CLK => CLK, X => contr_vect(3 downto 0), Y => NAME(7));

end Behavioral;
