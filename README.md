# TikkunCoin
Fiat-backed stable coin project

Tikkun is translated as to “fix” or “repair” which is based on the concept of repairing the world. This is our mission at Tikkun; We are going to repair the cryptocurrency volatility, thereby repairing the original idea of cryptocurrencies as a functioning money and currency.

Tikkun is the stable cryptocurrency tailor made for South Africans to transact, save and earn interest. It is now possible to enter the exciting cryptocurrency space without the concern of volatility. 
Tikkun coin will be backed by a 1:1 ratio of South African Rands which are divided into a cash and safe government bond investment portfolio. Through this investment, you will receive monthly interest on your holdings for everyday that you hold Tikkun. 

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

The following is a list of the software that you will need to install before you can deploy the project on your machine.
```
* VirtualBox (if you are not running a Unix based machine.)
* Go-ETHereum
* Ganache
* NodeJS and NPM
* Truffle
* SolC
* Visual code editor
* MetaMask
```

### Installing

*VirtualBox* can be downloaded from [here](https://www.virtualbox.org/wiki/Downloads)

*Geth (Go Ethereum)* is the the command line interface for running a full ethereum node implemented in Go. The full wiki is available [here](https://github.com/ethereum/go-ethereum/wiki). [Here](https://github.com/cogeorg/teaching/wiki/Installing-Geth) you will find brief instructions on how to get a node up and running using the command line interface.

*Ganache* You do not need a private or test node if you want to develop and test your smart contracts. A node emulator is an easy to handle alternative. Ganache is an emulated personal node for Ethereum development, that you can use to deploy contracts, develop your applications, and run tests. It is available as both a desktop application as well as a command-line tool (formerly known as the TestRPC). The installation instructions are available [here] (https://github.com/cogeorg/teaching/wiki/Ganache).

*NodeJS and NPM* installation instructions can be found [here] (https://github.com/cogeorg/teaching/wiki/Installing-NodeJS-and-NPM).

*Truffle* is a world class development environment, testing framework and asset pipeline for Ethereum, aiming to make life as an Ethereum developer easier. The installation isntructions can be found [her](https://github.com/cogeorg/teaching/wiki/Installing-Truffle). The following [link](https://github.com/cogeorg/teaching/wiki/Truffle) gives instructions on how to set up a Truffle project

*MetaMask* is a bridge that allows you to visit the distributed web of tomorrow in your browser today. It allows you to run Ethereum dApps right in your browser without running a full Ethereum node. You can find the MetaMask browswer extension [here](https://metamask.io/)

*Visual Studio Code* was the editor used in this project. It can be downloaded from [here](https://code.visualstudio.com/ )


## Running the tests

In order to run the test you need to run the following commands in the project directory:
```
truffle develop --log
```
This will start an Ethereum emulator
```
 truffle test
```
This will run all the tests in the test directory

## Deployment

Start up your Ganache and run the following command to deploy the project. 
```
truffle migrate --network ganche
```
The command to redeploy the contracts once you have made changes to them is:
```
truffle migrate --network ganache --reset --compile-all
```

Lite Server is a lightweight HTTP server that will serve our DApp when we run it. The following commands starts up the lite server
```
npm run dev
```
A new tab running on localhost:3000 should open in your browser.
## Built With

* [Solidity](https://solidity.readthedocs.io/en/v0.4.24/) - The programming language used
* [Bootstrap](https://getbootstrap.com/) - The framework used to build the front end


## Authors

* **Thandile Xiphu**
* **Ashley Flavish**
* **Jothi Moodley**
* **Samuel Ngoash**

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

