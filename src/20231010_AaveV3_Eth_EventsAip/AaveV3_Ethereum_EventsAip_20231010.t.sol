// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovHelpers} from 'aave-helpers/GovHelpers.sol';
import {AaveGovernanceV2} from 'aave-address-book/AaveGovernanceV2.sol';
import {ProtocolV2TestBase} from 'aave-helpers/ProtocolV2TestBase.sol';
import {AaveV2Ethereum, AaveV2EthereumAssets} from 'aave-address-book/AaveV2Ethereum.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';

import {AaveV3_Ethereum_GHOFunding_20230926} from './AaveV3_GHO_Funding.sol';
import {AaveMisc} from 'aave-address-book/AaveMisc.sol';
import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';
import {AaveV3_Ethereum_EventsAip_20231010} from './AaveV3_Ethereum_EventsAip_20231010.sol';
import 'forge-std/console.sol';

/**
 * @dev Test for AaveV3_Ethereum_EventsAip_20231010
 * command: make test-contract filter=AaveV3_Ethereum_EventsAip_20231010
 */

contract AaveV3_Ethereum_EventsAip_20231010_Test is ProtocolV2TestBase {
  AaveV3_Ethereum_EventsAip_20231010 internal proposal;

  address RECEIVER = 0x1c037b3C22240048807cC9d7111be5d455F640bd;
  address COLLECTOR = 0x464C71f6c2F760DdA6093dCB91C24c39e5d6e18c;

  uint256 public constant GHO_AMOUNT = 550_000e18;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 18334762);
    proposal = new AaveV3_Ethereum_EventsAip_20231010();
  }

  function testProposalExecution() public {
    AaveV3_Ethereum_EventsAip_20231010 payload = new AaveV3_Ethereum_EventsAip_20231010();
    uint256 ghoBalanceBeforeFunding = IERC20(AaveV3EthereumAssets.GHO_UNDERLYING).balanceOf(
      COLLECTOR
    );

    // Simulates having appropriate funds
    // https://app.aave.com/governance/proposal/?proposalId=347
    //0x121fE3fC3f617ACE9730203d2E27177131C4315e
    deal(
      address(AaveV3EthereumAssets.GHO_UNDERLYING),
      COLLECTOR,
      GHO_AMOUNT + ghoBalanceBeforeFunding
    );

    uint256 ghoBalanceAfterFunding = IERC20(AaveV3EthereumAssets.GHO_UNDERLYING).balanceOf(
      COLLECTOR
    );

    GovHelpers.executePayload(vm, address(payload), AaveGovernanceV2.SHORT_EXECUTOR);
    assertEq(ghoBalanceAfterFunding, ghoBalanceBeforeFunding + GHO_AMOUNT);
  }
}
