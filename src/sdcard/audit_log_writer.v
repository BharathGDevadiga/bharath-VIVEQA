`timescale 1ns/1ps

// Team 1 supplies a cryptographic digest that covers the complete event
// metadata.  Team 2 stores both the previous chain head and that digest; it
// intentionally does not replace security-core hashing with a weak RTL hash.
module audit_log_writer (
    input  wire         clk,
    input  wire         reset,
    input  wire         audit_request,
    output wire         audit_ready,
    input  wire [127:0] event_digest,
    output reg          record_valid,
    input  wire         record_ready,
    output reg [255:0]  record_data,
    output reg [127:0]  chain_head
);
    assign audit_ready = !record_valid;

    always @(posedge clk) begin
        if (reset) begin
            record_valid <= 1'b0;
            record_data <= 256'd0;
            chain_head <= 128'd0;
        end else begin
            if (record_valid && record_ready) begin
                record_valid <= 1'b0;
                chain_head <= record_data[127:0];
            end
            if (audit_request && !record_valid) begin
                record_data <= {chain_head, event_digest};
                record_valid <= 1'b1;
            end
        end
    end
endmodule
