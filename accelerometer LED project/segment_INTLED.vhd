library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;




----------------------------------------------------------------------------
--	PWM module for controlling LED intensity base on external input values
----------------------------------------------------------------------------
-- Author:  Ying Zhu
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
--Sets up PWM of LED RGB intensity base on 3 external 8bit input value, 0x00 is nothing and 0xFF is max intensity(Dangerously Bright)
--Red Blue and Green   
--																
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--The IEEE.std_logic_unsigned contains definitions that allow 
--std_logic_vector types to be used with the + operator to instantiate a 
--counter.
use IEEE.std_logic_unsigned.all;

entity segment_INTLED is
    Port ( SW 			: in  STD_LOGIC_VECTOR (6 downto 0);
           BTN 			: in  STD_LOGIC_VECTOR (4 downto 0);
           CLK 			: in  STD_LOGIC;
             
		  led_16g      : out STD_LOGIC;
		  led_17g      : out STD_LOGIC;
			  
		  led_16b     : out STD_LOGIC;
		  led_17b     : out std_logic;
			  
		  led_16r     : out STD_LOGIC;
		  led_17r     : out std_logic;
		  
		  contr_vect:  in std_logic_vector(7 downto 0);
		  contr_vect_b: in std_logic_vector(7 downto 0);
		  contr_vect_r: in std_logic_vector(7 downto 0)

			  
			  );
end segment_INTLED;

architecture Behavioral of segment_INTLED is

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





signal max_count: STD_LOGIC_VECTOR(7 downto 0) := x"FF";
signal reset: std_logic_vector(7 downto 0):= x"00";


signal clk_cntr_reg : std_logic_vector (4 downto 0) := (others=>'0'); 


begin
max_count <= x"FF";
reset <= x"00";
----------------------------------------------------------
------                LED Control                  -------
----------------------------------------------------------


---- This updates what value needs to sent to 7seg display bases on Switch status
process(CLK,SW(1 downto 0)) --Last 2 switches control what value you see on the 7seg
Begin
	if hexval >= max_count then -- btn0 is BTNC -- acts as reset for the hexval
			hexval<= reset;
			
	elsif rising_edge(clk) and hexval /= x"FF" then
			
				
				if (Count_divider > 3000) then
				hexval<= hexval+'1'; -- SW=11 will make hexval as counter ans show output... Its so fast that you only see top 4 digits updating... last 4 digits are changing but you will not be able to changing
				Count_divider <= Count_divider XOR Count_divider;
				else
				Count_divider <= Count_divider + 1;
				end if;

				
			
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



led_16g <= led_16gs;
led_17g <= led_17gs;

led_16b <= led_16bs;
led_17b <= led_17bs;

led_16r <= led_16rs;
led_17r <= led_17rs;





end Behavioral;
