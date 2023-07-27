const  updateInterval= 20;
const _pricefeed= ;
const _vrfCoordinator
const main = async () => {
    try {
      const nftContractFactory = await hre.ethers.getContractFactory(
        "BullBear"
      );
const  updateInterval= 20;
const _pricefeed= ;
const _vrfCoordinator = 
      const nftContract = await nftContractFactory.deploy();
  
      console.log("Contract deployed to:", nftContract.target);
      await nftContract.deploymentTransaction().wait(10);
      console.log("Verifying");
  
      await hre.run("verify:verify", {
        address: nftContract.target,
        constructorArguments: []
        
      });
      console.log("Veriied");
  
      process.exit(0);
  
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  
  
  };
    
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });