------------------------------------------------------------------------------
--                                                                          --
--                             GNAT EXAMPLE                                 --
--                                                                          --
--             Copyright (C) 2014, Free Software Foundation, Inc.           --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
--                                                                          --
--                                                                          --
--                                                                          --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

with Ada.Unchecked_Conversion;

--  with Registers;     use Registers;
with Interfaces.STM32.GPIO;  use Interfaces.STM32.GPIO;
with Interfaces.STM32.RCC;   use Interfaces.STM32.RCC;

package body LEDs is

   use type Interfaces.STM32.UInt16;

   function As_Word is new Ada.Unchecked_Conversion
     (Source => User_LED, Target => Interfaces.STM32.UInt16);


   procedure On (This : User_LED) is
   begin
      GPIOA_Periph.BSRR.BS.Val := As_Word (This);
   end On;


   procedure Off (This : User_LED) is
   begin
      GPIOA_Periph.BSRR.BR.Val := As_Word (This);
   end Off;


   All_LEDs  : constant Interfaces.STM32.UInt16 := Blue'Enum_Rep;

   pragma Compile_Time_Error
     (All_LEDs /= 16#0010#,
      "Invalid representation for All_LEDs");

   procedure All_Off is
   begin
      GPIOA_Periph.BSRR.BR.Val := All_LEDs;
   end All_Off;


   procedure All_On is
   begin
      GPIOA_Periph.BSRR.BS.Val := All_LEDs;
   end All_On;


   procedure Initialize is
      Mode_OUT     : constant := 1;
      Speed_100MHz : constant := 3;
      No_Pull      : constant := 0;
   begin
      --  Enable clock for GPIO-A
      RCC_Periph.AHB1ENR.GPIOAEN := 1;

      --  Configure PA4
      GPIOA_Periph.MODER.Arr (4 .. 4) := (others => Mode_OUT);
      GPIOA_Periph.OTYPER.OT.Arr (4 .. 4) := (others => 0);
      GPIOA_Periph.OSPEEDR.Arr (4 .. 4) := (others => Speed_100MHz);
      GPIOA_Periph.PUPDR.Arr (4 .. 4) := (others => No_Pull);
   end Initialize;


begin
   Initialize;
end LEDs;
