----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/14/2022 09:27:29 AM
-- Design Name: 
-- Module Name: I2S - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity I2S is
    Generic (   RATIO   : INTEGER := 8;
                WIDTH   : INTEGER := 16
                );
    Port (  MCLK     : in STD_LOGIC;
            nReset   : in STD_LOGIC;
            LRCLK    : out STD_LOGIC;
            SCLK     : out STD_LOGIC;
            SD       : out STD_LOGIC
            );
end I2S;
architecture I2S_Arch of I2S is

    type State_t is (State_Reset, State_WaitForReady, State_IncreaseAddress, State_WaitForStart);

    signal CurrentState : State_t    := State_Reset;

    signal Tx  : STD_LOGIC_VECTOR(((2 * WIDTH) - 1) downto 0)      := (others => '0');
    signal ROM_Data : STD_LOGIC_VECTOR((WIDTH - 1) downto 0)       := (others => '0');
    signal ROM_Address  : STD_LOGIC_VECTOR(6 downto 0)             := (others => '0');

    signal Ready        : STD_LOGIC;
    signal SCLK_Int     : STD_LOGIC                                         := '0';

    component I2S_Transmitter is
        Generic (   WIDTH   : INTEGER := 16
                    );
        Port (  Clock   : in STD_LOGIC;
                nReset  : in STD_LOGIC;
                Ready   : out STD_LOGIC;
                Tx      : in STD_LOGIC_VECTOR(((2 * WIDTH) - 1) downto 0);
                LRCLK   : out STD_LOGIC;
                SCLK    : out STD_LOGIC;
                SD      : out STD_LOGIC
                );
    end component;

    component SineROM is
        Port (  Address : in STD_LOGIC_VECTOR(6 downto 0);
                Clock   : in STD_LOGIC;
                DataOut : out STD_LOGIC_VECTOR(15 downto 0)
                );
    end component SineROM;

begin

    Transmitter : I2S_Transmitter generic map(  WIDTH => WIDTH
                                                )
                                  port map(     Clock => SCLK_Int,
                                                nReset => nReset,
                                                Ready => Ready,
                                                Tx => Tx,
                                                LRCLK => LRCLK,
                                                SCLK => SCLK,
                                                SD => SD
                                                );

    ROM : SineROM port map (Clock => MCLK,
                            Address => ROM_Address,
                            DataOut => ROM_Data
                            );

    process
        variable Counter    : INTEGER := 0;
    begin
        wait until rising_edge(MCLK);
        if(Counter < ((RATIO / 2) - 1)) then
            Counter := Counter + 1;
        else
            Counter := 0;
            SCLK_Int <= not SCLK_Int;
        end if;

        if(nReset = '0') then
            Counter := 0;
            SCLK_Int <= '0';
        end if;
    end process;

    process
        variable WordCounter    : INTEGER := 0;
    begin
        wait until rising_edge(MCLK);
        case CurrentState is
            when State_Reset =>
                WordCounter := 0;
                CurrentState <= State_WaitForReady;
            when State_WaitForReady =>
                if(Ready = '1') then
                    CurrentState <= State_WaitForStart;
                else
                    CurrentState <= State_WaitForReady;
                end if;
            when State_WaitForStart =>
                ROM_Address <= STD_LOGIC_VECTOR(to_unsigned(WordCounter, ROM_Address'length));
                Tx <= x"0000" & ROM_Data;
                if(Ready = '0') then
                    CurrentState <= State_IncreaseAddress;
                else
                    CurrentState <= State_WaitForStart;
                end if;
            when State_IncreaseAddress =>
                if(WordCounter < 99) then
                    WordCounter := WordCounter + 1;
                else
                    WordCounter := 0;
                end if;
                CurrentState <= State_WaitForReady;

        end case;
        if(nReset = '0') then
            CurrentState <= State_Reset;
        end if;
    end process;
end I2S_Arch;