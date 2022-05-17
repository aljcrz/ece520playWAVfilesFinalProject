library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xpm;
use xpm.vcomponents.all;

entity AXIS_I2S is
    Generic (   RATIO   : INTEGER := 8;
                WIDTH   : INTEGER := 16
                );
    Port (  MCLK        : in STD_LOGIC;
            nReset      : in STD_LOGIC;
            LRCLK       : out STD_LOGIC;
            SCLK        : out STD_LOGIC;
            SD          : out STD_LOGIC;
            ACLK        : in STD_LOGIC;
            ARESETn     : in STD_LOGIC;
            TDATA_RXD   : in STD_LOGIC_VECTOR(31 downto 0);
            TREADY_RXD  : out STD_LOGIC;
            TVALID_RXD  : in STD_LOGIC
            );
end AXIS_I2S;

architecture AXIS_I2S_Arch of AXIS_I2S is
    type AXIS_State_t is (State_Reset, State_WaitForTransmitterReady, State_WaitForValid, State_WaitForTransmitterBusy);
    signal CurrentState : AXIS_State_t    := State_Reset;
    signal Tx_AXI : STD_LOGIC_VECTOR(((2 * WIDTH) - 1) downto 0) := (others => '0');
    signal Ready_AXI : STD_LOGIC;
    signal Tx_Transmitter : STD_LOGIC_VECTOR(((2 * WIDTH) - 1) downto 0) := (others => '0');
    signal Ready_Transmitter    : STD_LOGIC;
    signal SCLK_Int             : STD_LOGIC := '0';
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

begin

    Transmitter : I2S_Transmitter generic map ( WIDTH => WIDTH
                                                )
                                  port map(     Clock => SCLK_Int,
                                                nReset => nReset,
                                                Ready => Ready_Transmitter,
                                                Tx => Tx_Transmitter,
                                                LRCLK => LRCLK,
                                                SCLK => SCLK,
                                                SD => SD
                                                );
   xpm_cdc_Data : xpm_cdc_gray generic map (    DEST_SYNC_FF => 4,
                                                SIM_ASSERT_CHK => 0,
                                                SIM_LOSSLESS_GRAY_CHK => 0,
                                                WIDTH => (2 * WIDTH)
                                                )
                                    port map (  src_clk => ACLK,
                                                src_in_bin => Tx_AXI,
                                                dest_clk => MCLK,
                                                dest_out_bin => Tx_Transmitter
                                                );
   xpm_cdc_Ready : xpm_cdc_single generic map ( DEST_SYNC_FF => 4,
                                                SRC_INPUT_REG => 1
                                                )
                                    port map (  src_clk => MCLK,
                                                src_in => Ready_Transmitter,
                                                dest_clk => ACLK,
                                                dest_out => Ready_AXI
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
    begin
        wait until rising_edge(ACLK);
        case CurrentState is
            when State_Reset =>
                Tx_AXI <= (others => '0');
                CurrentState <= State_WaitForTransmitterReady;
            when State_WaitForTransmitterReady =>
                if(Ready_AXI = '1') then
                    TREADY_RXD <= '1';
                    CurrentState <= State_WaitForValid;
                else
                    TREADY_RXD <= '0';
                    CurrentState <= State_WaitForTransmitterReady;
                end if;
            when State_WaitForValid =>                        
                if(TVALID_RXD = '1') then
                    TREADY_RXD <= '0';
                    Tx_AXI <= TDATA_RXD;
                    CurrentState <= State_WaitForTransmitterBusy;
                else
                    TREADY_RXD <= '1';
                    CurrentState <= State_WaitForValid;
                end if;
            when State_WaitForTransmitterBusy =>
                if(Ready_AXI = '0') then
                    CurrentState <= State_WaitForTransmitterReady;
                else
                    CurrentState <= State_WaitForTransmitterBusy;
                end if;
        end case;
        if(ARESETn = '0') then
            CurrentState <= State_Reset;
        end if;
    end process;
end AXIS_I2S_Arch;