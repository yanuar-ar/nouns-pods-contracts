const { task, types } = require('hardhat/config');

task('deploy', 'Deploy contract')
  .addOptionalParam('descriptor', 'NounsComposableDescriptor address', '0x', types.string)
  .addOptionalParam('seeder', 'NounsSeeder address', '0x', types.string)
  .setAction(async ({ descriptor, seeder }, { ethers, upgrades }) => {
    const NounsPods = await ethers.getContractFactory('NounsPods');

    const nounsPods = await NounsPods.deploy('', { gasLimit: 3000000 });

    await nounsPods.deployed(descriptor, seeder);

    console.log('Contract deployed to: ', NounsPods.address);
  });
