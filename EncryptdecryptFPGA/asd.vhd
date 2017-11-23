--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

PACKAGE rc5_pkg IS
 TYPE S_ARRAY IS ARRAY (0 TO 25) OF STD_LOGIC_VECTOR (31 DOWNTO 0);
 TYPE  L_ARRAY IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR (31 DOWNTO 0);
END rc5_pkg;


