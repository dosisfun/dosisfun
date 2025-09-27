sncast --account dojo_sepolia \
declare \
--url https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_8/NWCu9tuBdPGQBWPnfgyzF \
--contract-name MyToken


sncast --account dojo_sepolia \
deploy \
--url https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_8/NWCu9tuBdPGQBWPnfgyzF \
--class-hash 0x014b9b68fab33631eff047d12781ea668e0a74595694cb2008c8f37f743f2121 \
--arguments '0x00dba4d5ba495338b74aceac92ddc26afff9319d675e09db0aadba40cc606245,0x00dba4d5ba495338b74aceac92ddc26afff9319d675e09db0aadba40cc606245,1000000000000000000,0x00dba4d5ba495338b74aceac92ddc26afff9319d675e09db0aadba40cc606245'