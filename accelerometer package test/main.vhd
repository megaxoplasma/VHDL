library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;




----------------------------------------------------------------------------
--	Accelerometer SPI set up Reference template
----------------------------------------------------------------------------
-- Author:  Ying Zhu
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
--	This is simply a template for setting up the Nexys DDR4, This links the SPI chip interface to the accelerometer controler and to 
--the Accelerometer external ports themselves. 	
		
--This code will not pass the route and map and implementation stage, it will only synthesize
-- as it is, it is a raw template for "Using the accelerometr" generally. 

--To fully use this code you will have to map other external factors such as LED Switches etc to the UCF in addition to what is provided
--for the purpose of your own project.											
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.STD_LOGIC_ARITH.ALL;

--The IEEE.std_logic_unsigned contains definitions that allow 
--std_logic_vector types to be used with the + operator to instantiate a 
--counter.
use IEEE.std_logic_unsigned.all;

entity SevenSeg_Demo is
    Port ( SW 			: in  STD_LOGIC_VECTOR (15 downto 0);
           BTN 			: in  STD_LOGIC_VECTOR (4 downto 0);
           CLK 			: in  STD_LOGIC;
           LED 			: out  STD_LOGIC_VECTOR (15 downto 0);
           SSEG_CA 		: out  STD_LOGIC_VECTOR (7 downto 0);
           SSEG_AN 		: out  STD_LOGIC_VECTOR (7 downto 0);
		    

		-- SPI Interface signals for the ADXL362 accelerometer
			sclk           : out STD_LOGIC;
			mosi           : out STD_LOGIC;
			miso           : in STD_LOGIC;
			ss             : out STD_LOGIC
    
			  );
end SevenSeg_Demo;

architecture Behavioral of SevenSeg_Demo is
--This Component converts the values into Hex for display purposes
component Hex2LED 
port (CLK: in STD_LOGIC;
 X: in STD_LOGIC_VECTOR (3 downto 0); 
 Y: out STD_LOGIC_VECTOR (7 downto 0)); 
end component; 

type arr is array(0 to 22) of std_logic_vector(7 downto 0);
signal NAME: arr;

signal clk2: STD_LOGIC;
signal clk_100MHZ: STD_LOGIC_VECTOR(63 downto 0); --Clock divider





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

signal count_divider: std_logic_vector(40 downto 0);



signal max_count: STD_LOGIC_VECTOR(7 downto 0) := x"FF";



signal clk_cntr_reg : std_logic_vector (4 downto 0) := (others=>'0'); 

--------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Author:  Albert Fazakas adapted from Sam Bobrowicz and Mihaita Nagy
--          Copyright 2014 Digilent, Inc.
----------------------------------------------------------------------------

-- Design Name:    Nexys4 DDR User Demo
-- Module Name:    Nexys4DdrUserDemo - Behavioral 
-- Project Name: 
-- Target Devices: Nexys4 DDR Development Board, containing a XC7a100t-1 csg324 device
-- Tool versions: 
-- Description: 
-- This module represents the top - level design of the Nexys4 DDR User Demo.
-- The project connects to the VGA display in a 1280*1024 resolution and displays various
-- items on the screen:
--    - a Digilent / Analog Devices logo
--
--    - a mouse cursor, if an Usb mouse is connected to the board when the project is started
--
--    - the audio signal from the onboard ADMP421 Omnidirectional Microphone

--    - a small square representing the X and Y acceleration data from the ADXL362 onboard Accelerometer.
--      The square moves according the Nexys4 board position. Note that the X and Y axes 
--      on the board are exchanged due to the accelerometer layout on the Nexys4 board.
--      The accelerometer display also displays the acceleration magnitude, calculated as
--      SQRT( X^2 + Y^2 +Z^2), where X, Y and Z represent the acceleration value on the respective axes
--
--    - The FPGA temperature, the onboard ADT7420 temperature sensor temperature value and the accelerometer
--      temperature value
--
--    - The value of the R, G and B components sent to the RGB Leds LD16 and LD17
--
-- Other features:
--    - The 16 Switches (SW0..SW15) are connected to LD0..LD15 except when audio recording is done
--
--    - Pressing BTNL, BTNC and BTNR will toggle between Red, Green and Blue colors on LD16 and LD17
--      Color sweeping returns when BTND is pressed. BTND also togles between LD16, LD17, none or both
--
--    - Pressing BTNU will start audio recording for about 5S, then the audio data will be played back
--      on the Audio output. While recording, LD15..LD0 will show a progressbar moving to left, while
--      playing back, LD15..LD0 will show a progressbar moving to right
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------



--------------------------------------------
component AccelerometerCtl is
generic 
(
   SYSCLK_FREQUENCY_HZ : integer := 100000000;
   SCLK_FREQUENCY_HZ   : integer := 1000000;
   NUM_READS_AVG       : integer := 16;
   UPDATE_FREQUENCY_HZ : integer := 1000
);
port
(
 SYSCLK     : in STD_LOGIC; -- System Clock
 RESET      : in STD_LOGIC; -- Reset button on the Nexys4 board is active low

 -- SPI interface Signals
 SCLK       : out STD_LOGIC;
 MOSI       : out STD_LOGIC;
 MISO       : in STD_LOGIC;
 SS         : out STD_LOGIC;
 
-- Accelerometer data signals
 ACCEL_X_OUT    : out STD_LOGIC_VECTOR (11 downto 0);
 ACCEL_Y_OUT    : out STD_LOGIC_VECTOR (11 downto 0);
 ACCEL_MAG_OUT  : out STD_LOGIC_VECTOR (11 downto 0);
 ACCEL_TMP_OUT  : out STD_LOGIC_VECTOR (11 downto 0)
);
end component;

---------------------------------------------------------------
-- ADXL362 Accelerometer data signals
signal ACCEL_X    : STD_LOGIC_VECTOR (11 downto 0);
signal ACCEL_Y    : STD_LOGIC_VECTOR (11 downto 0);
signal ACCEL_MAG  : STD_LOGIC_VECTOR (11 downto 0);
signal ACCEL_TMP  : STD_LOGIC_VECTOR (11 downto 0);

-- 100 MHz buffered clock signal
signal clk_100MHz_buf : std_logic;
-- 200 MHz buffered clock signal
signal clk_200MHz_buf : std_logic;
signal reset: STD_LOGIC;


-------------------------------------------------------------------------------------------------------

begin
max_count <= x"FF";



----------------------------------------------------------------------------------
-- Accelerometer Controller
----------------------------------------------------------------------------------
   Inst_AccelerometerCtl: AccelerometerCtl
   generic map
   (
        SYSCLK_FREQUENCY_HZ   => 100000000,
        SCLK_FREQUENCY_HZ     => 100000,
        NUM_READS_AVG         => 16,
        UPDATE_FREQUENCY_HZ   => 1000
   )
   port map
   (
       SYSCLK     => clk,
       RESET      => reset, 
       -- Spi interface Signals
       SCLK       => sclk,
       MOSI       => mosi,
       MISO       => miso,
       SS         => ss,
     
      -- Accelerometer data signals
       ACCEL_X_OUT   => ACCEL_X,
       ACCEL_Y_OUT   => ACCEL_Y,
       ACCEL_MAG_OUT => ACCEL_MAG,
       ACCEL_TMP_OUT => ACCEL_TMP
   );













----------------------------------------------------------
------                LED Control                  -------
----------------------------------------------------------

with BTN(4) select --btn4 IS BTNU
	LED <= SW 			when '0',
			 "0000000000000000" when others;

---- This updates what value needs to sent to 7seg display bases on Switch status
process(CLK,SW(1 downto 0),hexval) --Last 2 switches control what value you see on the 7seg
Begin
	if hexval >= max_count then -- btn0 is BTNC -- acts as reset for the hexval
			hexval<= "00000000";
			
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

----------------------------------------100Mhz clock

process(clk,clk_100MHZ)
begin
if clk'EVENT and clk = '1' then
	if clk_100MHZ /= 100  then
		clk_100MHZ <= clk_100MHZ + 1;
	elsif clk_100MHZ = 100 and clk2 = '0' then
		clk_100MHZ <= x"0000000000000001";
		clk2 <= '1';
	elsif clk_100MHZ = 20000000 and clk2 = '1' then
		clk_100MHZ <= x"0000000000000001";
		clk2 <= '0';
else

end if;
end if;

end process;



















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


--CONV1: Hex2LED port map (CLK => CLK, X => contr_vect_r(7 downto 4), Y => NAME(0));
--CONV2: Hex2LED port map (CLK => CLK, X => contr_vect_r(3 downto 0), Y => NAME(1));
CONV3: Hex2LED port map (CLK => CLK, X => ACCEL_Y(11 downto 8), Y => NAME(2));
CONV4: Hex2LED port map (CLK => CLK, X => ACCEL_Y(7 downto 4), Y => NAME(3));		
--CONV5: Hex2LED port map (CLK => CLK, X => ACCEL_Y(3 downto 0), Y => NAME(4));
CONV6: Hex2LED port map (CLK => CLK, X => ACCEL_X(11 downto 8), Y => NAME(5));
CONV7: Hex2LED port map (CLK => CLK, X => ACCEL_X(7 downto 4), Y => NAME(6));
--CONV8: Hex2LED port map (CLK => CLK, X => ACCEL_X(3 downto 0), Y => NAME(7));

end Behavioral;
