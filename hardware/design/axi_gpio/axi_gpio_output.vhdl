--------------------------------------------------------------------------------
--
-- Component: axi_gpio_output
--
-- Has a 4bit wide address space, to address 4 GPIO pins.
--
-- Based loosely on:
-- - https://www.webpages.uidaho.edu/~jfrenzel/440/Handouts/Xilinx%20Vivado/Embedded%20Processor/axi_slave.pdf
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity axi_gpio_output is
  port (
    --* AXI4-Lite Interface

    --? Notes:
    --? - `in` means the signal is driven by the master
    --? - `out` means the signal is driven by the slave (this component)

    -- Clock and Reset
    S_AXI_ACLK    : in  STD_LOGIC;
    S_AXI_ARESETN : in  STD_LOGIC;

    -- Read Address Channel
    S_AXI_ARADDR  : in  STD_LOGIC_VECTOR(31 downto 0);
    S_AXI_ARVALID : in  STD_LOGIC;
    S_AXI_ARREADY : out STD_LOGIC;
    -- Read Data Channel
    S_AXI_RDATA   : out STD_LOGIC_VECTOR(31 downto 0);
    S_AXI_RRESP   : out STD_LOGIC_VECTOR(1 downto 0);
    S_AXI_RVALID  : out STD_LOGIC;
    S_AXI_RREADY  : in  STD_LOGIC;

    -- Write Address Channel
    S_AXI_AWADDR  : in  STD_LOGIC_VECTOR(31 downto 0);
    S_AXI_AWVALID : in  STD_LOGIC;
    S_AXI_AWREADY : out STD_LOGIC;
    -- Write Data Channel
    S_AXI_WDATA   : in  STD_LOGIC_VECTOR(31 downto 0);
    S_AXI_WSTRB   : in  STD_LOGIC_VECTOR(3 downto 0);
    S_AXI_WVALID  : in  STD_LOGIC;
    S_AXI_WREADY  : out STD_LOGIC;
    -- Write Response Channel
    S_AXI_BRESP   : out STD_LOGIC_VECTOR(1 downto 0);
    S_AXI_BVALID  : out STD_LOGIC;
    S_AXI_BREADY  : in  STD_LOGIC;

    --* GPIO Interface

    -- GPIO Data
    GPIO          : out STD_LOGIC_VECTOR(3 downto 0)
  );
end entity;

architecture rtl of axi_gpio_output is

  signal gpio_data_register : STD_LOGIC_VECTOR(3 downto 0);

  alias clk                 : STD_LOGIC is S_AXI_ACLK;
  alias reset               : STD_LOGIC is S_AXI_ARESETN;

begin

  --* GPIO Interface
  GPIO           <= gpio_data_register;

  --* AXI4-Lite Interface
  process (clk, reset)
  begin
    if rising_edge(clk) then
      if reset = '1' then

        --* Reset

        -- Read Address Channel
        S_AXI_ARREADY      <= '0';
        -- Read Data Channel
        S_AXI_RDATA        <= (others => '0');
        S_AXI_RRESP        <= (others => '0');
        S_AXI_RVALID       <= '0';

        -- Write Address Channel
        S_AXI_AWREADY      <= '0';
        -- Write Data Channel
        S_AXI_WREADY       <= '0';
        -- Write Response Channel
        S_AXI_BRESP        <= (others => '0');
        S_AXI_BVALID       <= '0';

        -- Signals
        gpio_data_register <= (others => '0');

      else

        --* Read Flow

        S_AXI_ARREADY <= '0';
        S_AXI_RVALID <= '0';

        if S_AXI_ARVALID = '1' then

          S_AXI_ARREADY <= '1';

          S_AXI_RDATA   <= (others => '0');
          S_AXI_RRESP   <= "10";
          case S_AXI_ARADDR is
            when X"00000000" =>
              S_AXI_RDATA(3 downto 0) <= gpio_data_register;
              S_AXI_RRESP             <= "00";
            when others =>
              null;
          end case;
          S_AXI_RVALID <= '1';

        end if;

        --* Write Flow

        S_AXI_AWREADY <= '0';
        S_AXI_WREADY <= '0';
        S_AXI_BVALID <= '0';

        if S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' then

          S_AXI_AWREADY <= '1';
          S_AXI_WREADY  <= '1';

          S_AXI_BRESP   <= "10";
          case S_AXI_AWADDR is
            when X"00000000" =>
              if S_AXI_WSTRB(0) = '1' then
                gpio_data_register <= S_AXI_WDATA(3 downto 0);
                S_AXI_BRESP        <= "00";
              end if;
            when others =>
              null;
          end case;
          S_AXI_BVALID <= '1';

        end if;

      end if;
    end if;
  end process;

end architecture;
