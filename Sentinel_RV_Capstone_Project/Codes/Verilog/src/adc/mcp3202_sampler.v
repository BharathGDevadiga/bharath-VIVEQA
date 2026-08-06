`timescale 1ns/1ps

module mcp3202_sampler #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer SPI_HZ = 1_000_000,
    parameter integer SAMPLE_HZ = 20
) (
    input  wire       clk,
    input  wire       reset,
    input  wire       force_sample,
    input  wire       channel,
    output reg [11:0] sample_value,
    output reg        sample_valid,
    output wire       busy,
    output wire       spi_sck,
    output wire       spi_mosi,
    input  wire       spi_miso,
    output wire       adc_cs_n
);
    
    localparam integer SAMPLE_DIV = (CLK_HZ / SAMPLE_HZ > 0) ? (CLK_HZ / SAMPLE_HZ) : 1;
    localparam integer COUNT_W = (SAMPLE_DIV <= 1) ? 1 : $clog2(SAMPLE_DIV);
    
    reg [COUNT_W-1:0] sample_count;
    reg start;
    reg [23:0] command_word;
    wire [23:0] received_word;
    wire spi_done;

    spi_master #(.CLK_HZ(CLK_HZ), .SPI_HZ(SPI_HZ), .DATA_WIDTH(24)) spi (
        .clk(clk), .reset(reset), .start(start), .tx_data(command_word),
        .rx_data(received_word), .busy(busy), .done(spi_done), .sck(spi_sck),
        .mosi(spi_mosi), .miso(spi_miso), .cs_n(adc_cs_n)
    );

    always @(posedge clk) begin
        if (reset) begin
            sample_count <= {COUNT_W{1'b0}};
            start <= 1'b0;
            command_word <= 24'd0;
            sample_value <= 12'd0;
            sample_valid <= 1'b0;
            
        end else begin
            start <= 1'b0;
            sample_valid <= 1'b0;
            if (spi_done) begin
                
                sample_value <= received_word[11:0];
                sample_valid <= 1'b1;
            end
            if (!busy) begin
                
                if (force_sample || sample_count == SAMPLE_DIV - 1) begin
                    
                    sample_count <= {COUNT_W{1'b0}};
                    // MCP3202 command: start, single-ended, channel, MSB-first.
                    command_word <= channel ? 24'b00000111_00000000_00000000 :
                                              24'b00000110_00000000_00000000;
                    start <= 1'b1;
                    
                end else
                    sample_count <= sample_count + 1'b1;
            end
        end
    end
endmodule
