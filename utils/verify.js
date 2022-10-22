const { run } = require("hardhat")

const verify = async (contractAddress, args) => {
    console.log("Verifying the contract")
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
            contract: "contract/OurToken.sol",
        })
    } catch (error) {
        if (error.message.toLowerCase().includes("already verified")) {
            console.log("Contract already verified")
        } else {
            console.log(error)
        }
    }
}

module.exports = { verify }
