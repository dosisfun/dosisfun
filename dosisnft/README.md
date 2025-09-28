sncast --account dojo_sepolia \
declare \
--url https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_8/NWCu9tuBdPGQBWPnfgyzF \
--contract-name MyToken


sncast --account dojo_sepolia \
deploy \
--url https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_8/NWCu9tuBdPGQBWPnfgyzF \
--class-hash 0x046a89e12f19d5faeb311076fb91e737a104fa04ebfbbcfd5a44ae550933bdee \
--arguments '0x00dba4d5ba495338b74aceac92ddc26afff9319d675e09db0aadba40cc606245,0x00dba4d5ba495338b74aceac92ddc26afff9319d675e09db0aadba40cc606245,1000000000000000000,0x00dba4d5ba495338b74aceac92ddc26afff9319d675e09db0aadba40cc606245'