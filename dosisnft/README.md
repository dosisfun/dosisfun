sncast --account dojo_sepolia \
declare \
--url https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_8/wlv5uvdkI7sD1rz8bFQfb \
--contract-name MyToken


sncast --account dojo_sepolia \
deploy \
--url https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_8/wlv5uvdkI7sD1rz8bFQfb \
--class-hash 0x00f4368f5f97340394ce0119f822ada1e0d6257cb5e147838ca42446d57eaa08 \
--arguments '0x00dba4d5ba495338b74aceac92ddc26afff9319d675e09db0aadba40cc606245,0x00dba4d5ba495338b74aceac92ddc26afff9319d675e09db0aadba40cc606245,1000000000000000000,0x00dba4d5ba495338b74aceac92ddc26afff9319d675e09db0aadba40cc606245'