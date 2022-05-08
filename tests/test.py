from brownie import Lottery, accounts, config, network
from web3 import Web3

def get_fee():
    account = accounts[0]
    lottery = Lottery.deploy(config["networks"][network.show_active()]["eth_usd"], {"from": account})
    assert lottery.getFee() > Web3.toWei(0.018, "ether")