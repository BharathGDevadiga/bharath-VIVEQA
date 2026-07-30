# SD Audit Storage

`audit_log_writer` stores `{previous_digest,event_digest}` and advances its
chain head only after `sd_logger` accepts the record. System Subsystem must calculate
`event_digest` over the event metadata and previous hash; Peripheral Subsystem never replaces
that operation with a non-cryptographic hash.

`sd_card_init` automatically clocks the card then runs CMD0, CMD8,
CMD55/ACMD41 (HCS) and CMD58. `team2_top` holds audit records until it
reports ready. The initialization path accepts SDHC cards only; add an SDSC
addressing branch if legacy byte-addressed cards must be supported.

`sd_sector_writer` writes a 32-byte record at the start of a 512-byte CMD24
SDHC sector. The remaining bytes are zero-filled.
