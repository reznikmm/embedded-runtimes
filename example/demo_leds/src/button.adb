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

with Ada.Interrupts.Names;
with Ada.Real_Time;           use Ada.Real_Time;
with Interfaces.STM32.EXTI;   use Interfaces.STM32.EXTI;
with Interfaces.STM32.GPIO;   use Interfaces.STM32.GPIO;
with Interfaces.STM32.RCC;    use Interfaces.STM32.RCC;
with Interfaces.STM32.SYSCFG; use Interfaces.STM32.SYSCFG;
with System.STM32;

package body Button is

   protected Button is
      pragma Interrupt_Priority;

      function Current_Period return Time_Span;

   private
      procedure Interrupt_Handler;
      pragma Attach_Handler
         (Interrupt_Handler,
          Ada.Interrupts.Names.EXTI2_Interrupt);

      Period    : Time_Span := Milliseconds (75);
      Last_Time : Time := Clock;
   end Button;

   Debounce_Time : constant Time_Span := Milliseconds (200);

   protected body Button is

      function Current_Period return Time_Span is
      begin
         return Period;
      end Current_Period;

      procedure Interrupt_Handler is
         Now : constant Time := Clock;
      begin
         --  Clear interrupt
         EXTI_Periph.PR.PR.Arr (2) := 1;

         --  Debouncing
         if Now - Last_Time >= Debounce_Time then
            Period := Period + Period;

            Last_Time := Now;
         end if;
      end Interrupt_Handler;

   end Button;

   function Current_Period return Ada.Real_Time.Time_Span is
   begin
      return Button.Current_Period;
   end Current_Period;

   procedure Initialize is
   begin
      --  Enable clock for GPIO-B
      RCC_Periph.AHB1ENR.GPIOBEN := 1;

      --  Configure PB2
      GPIOB_Periph.MODER.Arr (2) := System.STM32.Mode_IN;
      GPIOB_Periph.PUPDR.Arr (2) := System.STM32.No_Pull;

      --  Select PB2 for EXTI2
      SYSCFG_Periph.EXTICR1.EXTI.Arr (2) := 1;  --  PB

      --  Interrupt on rising edge
      EXTI_Periph.FTSR.TR.Arr (2) := 0;
      EXTI_Periph.RTSR.TR.Arr (2) := 1;
      EXTI_Periph.IMR.MR.Arr (2) := 1;
   end Initialize;

begin
   Initialize;
end Button;
