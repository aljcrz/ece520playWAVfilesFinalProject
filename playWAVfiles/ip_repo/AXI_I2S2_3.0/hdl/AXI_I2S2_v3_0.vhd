library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AXI_I2S2_v3_0 is
	generic (
		-- Users to add parameters here
                RATIO   : INTEGER := 8;
                WIDTH   : INTEGER := 16;
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
            MCLK        : in STD_LOGIC;
            nReset      : in STD_LOGIC;
            LRCLK       : out STD_LOGIC;
            SCLK        : out STD_LOGIC;
            SD          : out STD_LOGIC;
            ACLK        : in STD_LOGIC;
            ARESETn     : in STD_LOGIC;
            TDATA_RXD   : in STD_LOGIC_VECTOR(31 downto 0);
            TREADY_RXD  : out STD_LOGIC;
            TVALID_RXD  : in STD_LOGIC;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end AXI_I2S2_v3_0;

architecture arch_imp of AXI_I2S2_v3_0 is

	-- component declaration
	component AXI_I2S2_v3_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component AXI_I2S2_v3_0_S00_AXI;
	
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

-- Instantiation of Axi Bus Interface S00_AXI
AXI_I2S2_v3_0_S00_AXI_inst : AXI_I2S2_v3_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);
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
	-- User logic ends

end arch_imp;
