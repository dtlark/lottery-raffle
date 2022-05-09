from brownie import Lottery, accounts, config, network

FORKED_LOCAL_ENV = ["mainnet-fork"]
LOCAL_BC_ENV = ["development", "ganache-local"]

def get_account():
    if (network.show_active() in LOCAL_BC_ENV or network.show_active() in FORKED_LOCAL_ENV):
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])

def deploy():
    account = get_account()

def main():
    deploy()