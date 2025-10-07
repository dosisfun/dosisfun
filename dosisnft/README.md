sncast --account dojo_sepolia \
declare \
--url https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_8/wlv5uvdkI7sD1rz8bFQfb \
--contract-name MyToken


sncast --account dojo_sepolia \
deploy \
--url https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_8/wlv5uvdkI7sD1rz8bFQfb \
--class-hash 0x02ba04848662d5273b24382fa3de9ec49289e25c8089585995e146f5f49e89ae \
--arguments '0x00dba4d5ba495338b74aceac92ddc26afff9319d675e09db0aadba40cc606245,0x00dba4d5ba495338b74aceac92ddc26afff9319d675e09db0aadba40cc606245,1000000000000000000,0x00dba4d5ba495338b74aceac92ddc26afff9319d675e09db0aadba40cc606245'