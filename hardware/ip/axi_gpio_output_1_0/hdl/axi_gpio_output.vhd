library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_gpio_output is
  generic (
    -- Users to add parameters here

    C_GPIO_WIDTH       : INTEGER := 4;

    -- User parameters ends
    -- Do not modify the parameters beyond this line

    -- Parameters of Axi Slave Bus Interface S_AXI
    C_S_AXI_DATA_WIDTH : INTEGER := 32;
    C_S_AXI_ADDR_WIDTH : INTEGER := 4
  );
  port (
    -- Users to add ports here

    GPIO          : out STD_LOGIC_VECTOR(C_GPIO_WIDTH - 1 downto 0);

    -- User ports ends
    -- Do not modify the ports beyond this line

    -- Ports of Axi Slave Bus Interface S_AXI
    s_axi_aclk    : in  STD_LOGIC;
    s_axi_aresetn : in  STD_LOGIC;
    s_axi_awaddr  : in  STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH - 1 downto 0);
    s_axi_awprot  : in  STD_LOGIC_VECTOR(2 downto 0);
    s_axi_awvalid : in  STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata   : in  STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH - 1 downto 0);
    s_axi_wstrb   : in  STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH/8) - 1 downto 0);
    s_axi_wvalid  : in  STD_LOGIC;
    s_axi_wready  : out STD_LOGIC;
    s_axi_bresp   : out STD_LOGIC_VECTOR(1 downto 0);
    s_axi_bvalid  : out STD_LOGIC;
    s_axi_bready  : in  STD_LOGIC;
    s_axi_araddr  : in  STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH - 1 downto 0);
    s_axi_arprot  : in  STD_LOGIC_VECTOR(2 downto 0);
    s_axi_arvalid : in  STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rdata   : out STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH - 1 downto 0);
    s_axi_rresp   : out STD_LOGIC_VECTOR(1 downto 0);
    s_axi_rvalid  : out STD_LOGIC;
    s_axi_rready  : in  STD_LOGIC
  );
end axi_gpio_output;

architecture arch_imp of axi_gpio_output is

  -- component declaration
  component axi_gpio_output_slave_lite_v1_0_S_AXI is
    generic (
      C_GPIO_WIDTH       : INTEGER := 4;

      C_S_AXI_DATA_WIDTH : INTEGER := 32;
      C_S_AXI_ADDR_WIDTH : INTEGER := 4
    );
    port (
      GPIO          : out STD_LOGIC_VECTOR(C_GPIO_WIDTH - 1 downto 0);

      S_AXI_ACLK    : in  STD_LOGIC;
      S_AXI_ARESETN : in  STD_LOGIC;
      S_AXI_AWADDR  : in  STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH - 1 downto 0);
      S_AXI_AWPROT  : in  STD_LOGIC_VECTOR(2 downto 0);
      S_AXI_AWVALID : in  STD_LOGIC;
      S_AXI_AWREADY : out STD_LOGIC;
      S_AXI_WDATA   : in  STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH - 1 downto 0);
      S_AXI_WSTRB   : in  STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH/8) - 1 downto 0);
      S_AXI_WVALID  : in  STD_LOGIC;
      S_AXI_WREADY  : out STD_LOGIC;
      S_AXI_BRESP   : out STD_LOGIC_VECTOR(1 downto 0);
      S_AXI_BVALID  : out STD_LOGIC;
      S_AXI_BREADY  : in  STD_LOGIC;
      S_AXI_ARADDR  : in  STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH - 1 downto 0);
      S_AXI_ARPROT  : in  STD_LOGIC_VECTOR(2 downto 0);
      S_AXI_ARVALID : in  STD_LOGIC;
      S_AXI_ARREADY : out STD_LOGIC;
      S_AXI_RDATA   : out STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH - 1 downto 0);
      S_AXI_RRESP   : out STD_LOGIC_VECTOR(1 downto 0);
      S_AXI_RVALID  : out STD_LOGIC;
      S_AXI_RREADY  : in  STD_LOGIC
    );
  end component axi_gpio_output_slave_lite_v1_0_S_AXI;

begin

  -- Instantiation of Axi Bus Interface S_AXI
  axi_gpio_output_slave_lite_v1_0_S_AXI_inst : axi_gpio_output_slave_lite_v1_0_S_AXI
  generic map(
    C_GPIO_WIDTH       => C_GPIO_WIDTH,

    C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
    C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH
  )
  port map(
    GPIO          => GPIO,

    S_AXI_ACLK    => s_axi_aclk,
    S_AXI_ARESETN => s_axi_aresetn,
    S_AXI_AWADDR  => s_axi_awaddr,
    S_AXI_AWPROT  => s_axi_awprot,
    S_AXI_AWVALID => s_axi_awvalid,
    S_AXI_AWREADY => s_axi_awready,
    S_AXI_WDATA   => s_axi_wdata,
    S_AXI_WSTRB   => s_axi_wstrb,
    S_AXI_WVALID  => s_axi_wvalid,
    S_AXI_WREADY  => s_axi_wready,
    S_AXI_BRESP   => s_axi_bresp,
    S_AXI_BVALID  => s_axi_bvalid,
    S_AXI_BREADY  => s_axi_bready,
    S_AXI_ARADDR  => s_axi_araddr,
    S_AXI_ARPROT  => s_axi_arprot,
    S_AXI_ARVALID => s_axi_arvalid,
    S_AXI_ARREADY => s_axi_arready,
    S_AXI_RDATA   => s_axi_rdata,
    S_AXI_RRESP   => s_axi_rresp,
    S_AXI_RVALID  => s_axi_rvalid,
    S_AXI_RREADY  => s_axi_rready
  );

  -- Add user logic here

  -- User logic ends

end arch_imp;
