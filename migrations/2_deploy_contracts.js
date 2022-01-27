const BIAWhitelisted= artifacts.require("BIAWhitelisted");

module.exports = function (deployer) {
  
  deployer.deploy(BIAWhitelisted,'4265','0xF2Dec16aD61B58c5b914419548747c72eF451Dc5','0xbe050b2e55a4d3002d215bc90528c7711a3fd7e0','46893317702227400000000','1643673601','1651363201','1656633601','1672531201','1704067201');
};

/*
rate -> 4265
wallet -> 0xF2Dec16aD61B58c5b914419548747c72eF451Dc5 (for Test)
Token Address -> 0xbe050b2e55a4d3002d215bc90528c7711a3fd7e0 (for Test)
CAP -> 46893317702227400000000  (BNB value of 200000000 BIA Token as given rate)   
OpeningTime -> February 1, 2022 12:00:01 AM - 1643673601 (New value will be assigned during the deployment)
ClosingTime -> May 1, 2022 12:00:01 AM - 1651363201 (from new value, Three months)
ReleaseTime1 -> July 1, 2022 12:00:01 AM - 1656633601
ReleaseTime2 ->January 1, 2023 12:00:01 AM - 1672531201
ReleaseTime3 ->January 1, 2024 12:00:01 AM - 1704067201
*/
