`timescale 1ns/1ps

// Outbound frame: A5 | nonce[63:0] | sequence | AES-128 ciphertext | CRC-32/MPEG-2.
module packet_formatter (
    input  wire         clk,
    input  wire         reset,
    input  wire         aes_reset,
    input  wire         start,
    input  wire [127:0] plaintext,
    input  wire [127:0] key,
    input  wire [63:0]  nonce,
    input  wire [7:0]   sequence,
    output reg  [239:0] packet,
    output reg          packet_valid,
    output reg          busy
);
    localparam [2:0] IDLE = 3'd0, AES_START = 3'd1, AES_WAIT = 3'd2,
                     CRC_START = 3'd3, CRC_SEND = 3'd4, CRC_WAIT = 3'd5;
    reg [2:0] state;
    reg aes_start;
    reg crc_start;
    reg crc_data_valid;
    reg crc_data_last;
    reg [7:0] crc_data;
    reg [4:0] byte_index;
    reg [63:0] nonce_reg;
    reg [7:0] sequence_reg;
    reg [127:0] plaintext_reg;
    reg [127:0] key_reg;
    reg [127:0] cipher_reg;
    wire [127:0] aes_ciphertext;
    wire aes_busy;
    wire aes_done;
    wire [31:0] crc_value;
    wire crc_busy;
    wire crc_valid;

    aes128_encrypt aes (
        .clk(clk), .reset(reset | aes_reset), .start(aes_start), .plaintext(plaintext_reg), .key(key_reg),
        .ciphertext(aes_ciphertext), .busy(aes_busy), .done(aes_done)
    );
    crc32_mpeg2 crc (
        .clk(clk), .reset(reset), .start(crc_start), .data_valid(crc_data_valid), .data_byte(crc_data),
        .data_last(crc_data_last), .crc(crc_value), .busy(crc_busy), .crc_valid(crc_valid)
    );


    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            aes_start <= 1'b0;
            crc_start <= 1'b0;
            crc_data_valid <= 1'b0;
            crc_data_last <= 1'b0;
            crc_data <= 8'd0;
            byte_index <= 5'd0;
            nonce_reg <= 64'd0;
            sequence_reg <= 8'd0;
            plaintext_reg <= 128'd0;
            key_reg <= 128'd0;
            cipher_reg <= 128'd0;
            packet <= 240'd0;
            packet_valid <= 1'b0;
            busy <= 1'b0;
        end else begin
            aes_start <= 1'b0;
            crc_start <= 1'b0;
            crc_data_valid <= 1'b0;
            crc_data_last <= 1'b0;
            packet_valid <= 1'b0;
            if (aes_reset) begin
                state <= IDLE;
                busy <= 1'b0;
            end else begin
                case (state)
                    IDLE: if (start) begin
                        nonce_reg <= nonce;
                        sequence_reg <= sequence;
                        plaintext_reg <= plaintext;
                        key_reg <= key;
                        busy <= 1'b1;
                        state <= AES_START;
                    end
                    AES_START: begin
                        aes_start <= 1'b1;
                        state <= AES_WAIT;
                    end
                    AES_WAIT: if (aes_done) begin
                        cipher_reg <= aes_ciphertext;
                        state <= CRC_START;
                    end
                    CRC_START: begin
                        crc_start <= 1'b1;
                        byte_index <= 5'd0;
                        state <= CRC_SEND;
                    end
                    CRC_SEND: begin
                        if (byte_index == 0)
                            crc_data <= 8'hA5;
                        else if (byte_index <= 8)
                            crc_data <= nonce_reg >> (8 * (8 - byte_index));
                        else if (byte_index == 9)
                            crc_data <= sequence_reg;
                        else
                            crc_data <= cipher_reg >> (8 * (25 - byte_index));
                            
                        crc_data_valid <= 1'b1;
                        crc_data_last <= (byte_index == 5'd25);
                        if (byte_index == 5'd25)
                            state <= CRC_WAIT;
                        else
                            byte_index <= byte_index + 1'b1;
                    end
                    default: if (crc_valid) begin
                        packet <= {8'hA5, nonce_reg, sequence_reg, cipher_reg, crc_value};
                        packet_valid <= 1'b1;
                        busy <= 1'b0;
                        state <= IDLE;
                    end
                endcase
            end
        end
    end
endmodule
