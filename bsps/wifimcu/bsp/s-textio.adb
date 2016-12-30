------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--                       S Y S T E M . T E X T _ I O                        --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--          Copyright (C) 1992-2016, Free Software Foundation, Inc.         --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
-- You should have received a copy of the GNU General Public License along  --
-- with this library; see the file COPYING3. If not, see:                   --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

--  Minimal version of Text_IO body for use on STM32F411xx, using USART2

with Interfaces; use Interfaces;

with Interfaces.STM32;       use Interfaces.STM32;
with Interfaces.STM32.RCC;   use Interfaces.STM32.RCC;
with Interfaces.STM32.GPIO;  use Interfaces.STM32.GPIO;
with Interfaces.STM32.USART; use Interfaces.STM32.USART;
with System.STM32;           use System.STM32;
with System.BB.Parameters;

package body System.Text_IO is

   Baudrate : constant := 115_200;
   --  Bitrate to use

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
      use System.BB.Parameters;

      APB_Clock    : constant Positive := Positive (STM32.System_Clocks.PCLK1);
      Int_Divider  : constant Positive := (25 * APB_Clock) / (4 * Baudrate);
      Frac_Divider : constant Natural := Int_Divider rem 100;
   begin
      Initialized := True;

      RCC_Periph.APB1ENR.USART2EN := 1;
      RCC_Periph.AHB1ENR.GPIOAEN  := 1;

      GPIOA_Periph.MODER.Arr     (2 .. 3) := (Mode_AF,      Mode_AF);
      GPIOA_Periph.OSPEEDR.Arr   (2 .. 3) := (Speed_50MHz,  Speed_50MHz);
      GPIOA_Periph.OTYPER.OT.Arr (2 .. 3) := (Push_Pull,    Push_Pull);
      GPIOA_Periph.PUPDR.Arr     (2 .. 3) := (Pull_Up,      Pull_Up);
      GPIOA_Periph.AFRL.Arr      (2 .. 3) := (AF_USART2,    AF_USART2);

      USART2_Periph.BRR :=
        (DIV_Fraction => UInt4  (((Frac_Divider * 16 + 50) / 100) mod 16),
         DIV_Mantissa => UInt12 (Int_Divider / 100),
         others => <>);
      USART2_Periph.CR1 :=
        (UE => 1,
         RE => 1,
         TE => 1,
         others => <>);
      USART2_Periph.CR2 := (STOP => 1, others => <>);
      USART2_Periph.CR3 := (others => <>);
   end Initialize;

   -----------------
   -- Is_Tx_Ready --
   -----------------

   function Is_Tx_Ready return Boolean is
     (USART2_Periph.SR.TC = 1);

   -----------------
   -- Is_Rx_Ready --
   -----------------

   function Is_Rx_Ready return Boolean is
     (USART2_Periph.SR.RXNE = 1);

   ---------
   -- Get --
   ---------

   function Get return Character is (Character'Val (USART2_Periph.DR.DR));

   ---------
   -- Put --
   ---------

   procedure Put (C : Character) is
   begin
      USART2_Periph.DR.DR := Character'Pos (C);
   end Put;

   ----------------------------
   -- Use_Cr_Lf_For_New_Line --
   ----------------------------

   function Use_Cr_Lf_For_New_Line return Boolean is (True);
end System.Text_IO;
