// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../INecoToken.sol";

contract NecoAirdrop is Ownable {
    using SafeMath for uint;

    mapping (address=>bool) public whitelist;
    mapping (address=> bool) public claimed;
    bool claimEnabled = false;

    INecoToken public necoToken;
    // 20 neco for everyone， winner 200 people
    uint public necoTotalClaimedAmount = 0;
    uint public amountForEveryone = 20 * 1e18;

    // for that time, we may need to add whitelist 1 by 1, or we may init them at one time.
    constructor(INecoToken _necoToken) {
        necoToken = _necoToken;
        initWhitelist();
    }

    // start sale
    function enableClaim() external onlyOwner {
        require(necoToken.minters(address(this)), "Please set this contract to be a minter.");
        claimEnabled = true;
    }

    function stopClaim() external onlyOwner {
        claimEnabled = false;
    }

    function claim() external claimHasStarted {
        require(whitelist[msg.sender], "you are not in airdrop winner list.");
        require(claimed[msg.sender] == false, "you already claimed NECO.");

        necoToken.transfer(msg.sender, amountForEveryone);
        necoTotalClaimedAmount = necoTotalClaimedAmount.add(amountForEveryone);
        claimed[msg.sender] = true;
    }

    function initWhitelist() internal {
        whitelist[0xa1aA9732B554189D89F90d769AB60Ea5a188A9Fc] = true;
        whitelist[0x2383dAa750B09B338A09c27014228b24b3119999] = true;
        whitelist[0x1F5A1bf9891c9Db71585fBb24AB972541fe25b8d] = true;
        whitelist[0x00000E36688330D643e7a7f25440320049A6c210] = true;
        whitelist[0xDcb1B8a4BCd1c67C06b277066B0fEd84F1376be8] = true;
        whitelist[0x336Ab09A2C4A4FeF9956D8c10b5E34A265d76bBf] = true;
        whitelist[0x8DC2D0A7747aBC6fCE2b3581c7c0593374059b59] = true;
        whitelist[0x0B4C1e036D8a5e314B9b590E6293554D8C3a953e] = true;
        whitelist[0xCb87f05588c2fbd959FD5f45fA652572aDCCEfd6] = true;
        whitelist[0xd1739a0229B224c304238B3E6F09BC693d1A4229] = true;
        whitelist[0xE0530c5a8Ef2b4FdA3Ce4bdd5F211aC04d949045] = true;
        whitelist[0x33178B0047F63Fe86CFCcC41a0588f4BeC8f6481] = true;
        whitelist[0x29be8D24BE8ebFcE9d241364CdEc81a5b93F7C50] = true;
        whitelist[0x627EDCDE3C031fa21891eAc68cb685e3b243d98E] = true;
        whitelist[0x53CE838d63763Cf6272B22EbB8C56feff775d983] = true;
        whitelist[0x315f8FcD082A7f46467308F72301246D42C0253E] = true;
        whitelist[0x9FCC06AD3F1C6B2FBcA30EFFDEb5B7Fd82381516] = true;
        whitelist[0xFBee2cd18AD12cD8e8D5d3E683F2AD6d38f746E6] = true;
        whitelist[0x000003bC41855bff224cE7ADCf6687277da14621] = true;
        whitelist[0x6264552ecD792cD2ceD75C3ba61D5BE4865CDf1C] = true;
        whitelist[0xbE9A10Fc1e6Bf2B850b3d123911c1e8f828651d4] = true;
        whitelist[0xd8ee47E0B2f1f35BEc99C51f6a2E3a6Ce95E616D] = true;
        whitelist[0x20c65e7AF6f0555C1992E76E21A3BBa6d3E96bFf] = true;
        whitelist[0x5432dC6843Eb26cDFcf0E994D882b3328b1B1A17] = true;
        whitelist[0x27589783293f8Ba16164c55A31E00b08412c0f1B] = true;
        whitelist[0x73E7aF3178cDc78931ff22eb7A85EdB0413B7F65] = true;
        whitelist[0x369241958bA0795c98BA7B7A25EC3C52C088fD66] = true;
        whitelist[0x03863382E059A87c510B6d43C901850830cb1C9B] = true;
        whitelist[0x0D1A28a279F7c418Aa19bd173763E13c1743C833] = true;
        whitelist[0x47e3D0E6bd8289e3F7f72b26004Ed9d70F7d5460] = true;
        whitelist[0x20cCb8bAc40D91D799F09D35Ce0Ad476a443F389] = true;
        whitelist[0x48121a6D473288d9cC959aF28C6be88ba46eFEA6] = true;
        whitelist[0x2719e8e2B75C271F82ee188a8C14B77e483f172c] = true;
        whitelist[0xAe333742b411aC49DC4c15606C74C757Ab51B88b] = true;
        whitelist[0xbd8484BE6c713b5d4582C3525D7F195cD503282F] = true;
        whitelist[0xb187A1Dd0aDe9b1f3042caB4147fF6Fa9FD1E4F0] = true;
        whitelist[0x99c4bed2a1216386F7F06CFb9Ed6c3027d35223A] = true;
        whitelist[0x7e800429936e279ff26c4868006D82f148BF9cdB] = true;
        whitelist[0x38c6e2284340D3909Ed2ceD0f4CfA546a848A99C] = true;
        whitelist[0xc8aada7904c3e4fd55694bA8C24E232aD57b384D] = true;
        whitelist[0x0cFbF48e00a415EcE5F80Aca41a72a830ef6E764] = true;
        whitelist[0x369320339336fBf4cd25815B93532dc33b029841] = true;
        whitelist[0x85C4eD1b0ccD94a46E760f7ba7AF91E37C8CF9fc] = true;
        whitelist[0xfE08945f392CF1873f2c5b1bd7C7401E452153a8] = true;
        whitelist[0x06fef592AaF0658296525CbA27B72556c654e9a0] = true;
        whitelist[0xf294C051c6D47486f15ce0D33972fbcbF3Ba8Df9] = true;
        whitelist[0x53985CFa41a528ef9B0BAE17675927719382bfC8] = true;
        whitelist[0xb8Ae0eE9C06B6eDfd445D09224C7AAb813781669] = true;
        whitelist[0xad02A594FAeBeE9d4eF69a2c3e3820A8255781e2] = true;
        whitelist[0x25A3c766FA26d6C7416E3d25e141B4361BB46963] = true;
        whitelist[0x44a820B1FbcA0381E4d49ee28f6c15555FD10679] = true;
        whitelist[0x00FdDd34B163aa5774C533e0aa284359a5995163] = true;
        whitelist[0xb1D53CbD6eA38CE81DF05b2834987cAC3E6fA7CD] = true;
        whitelist[0x4668AC70dA4280239c7EC0AeBB04E7C51a5fAD12] = true;
        whitelist[0x03CCe6FD24644D9d392eF60339a6B3c2EEC5614d] = true;
        whitelist[0x0eA4d7C8259a1A6ab9BC38277073e0cB67ee164f] = true;
        whitelist[0xAFB2c01f5Ee0cb9D5BA04bA5B6398C3799E0c718] = true;
        whitelist[0x038A3a4552301FC6cFe5befe48FbE96FC47333b0] = true;
        whitelist[0xA2BA55d6D30e687D1C606F79ED49b1c489554541] = true;
        whitelist[0x19bEDB58a220Be91A89DCa6B3E6f8111fE34f050] = true;
        whitelist[0x4f639db159f6D0ec6B5e652496A496471bc230EF] = true;
        whitelist[0xefCc431e666da5044b4360957349B50aA7E9a209] = true;
        whitelist[0x22a429cEAA0391Bdd71B0718bcf8fdE5005EC2d6] = true;
        whitelist[0x57C7F75cD750a4A9aCa4f531A5F6C61e514a26Dc] = true;
        whitelist[0x37F5de789E445112F951809277E39FfCeB2A2eBA] = true;
        whitelist[0x00000084dE9F9B1E884bF3C0Ad28E867de7FDeb3] = true;
        whitelist[0xB75B356A79B7FcF6220bBDfa9f9180c70267b7bf] = true;
        whitelist[0xFaaaC21ab91BD8eF591E588cb71d4f35D8b5ac3c] = true;
        whitelist[0x118506179DF5edc9fD21caF32bbb12Cec513bf9f] = true;
        whitelist[0x2C39b217A6Bf479B56Ee22520D91A7aCb55Dcd51] = true;
        whitelist[0x4BdeAe6218071f704be47Ba6A2Ddb36062Fa6353] = true;
        whitelist[0xE2605d920ff0D422B7B01e1123CCB8ed75e54ecC] = true;
        whitelist[0xdece68f6Ae45ADde51504a6d09228bf09634b724] = true;
        whitelist[0x946ec00b3D9D1A70a4356b24f69AA468Abe83b25] = true;
        whitelist[0x17953556F61C21df4b3E151e21e155a55233D22E] = true;
        whitelist[0x33beE8fb3D40d9Db592cDa87eB5CeF43bE86b902] = true;
        whitelist[0x9bB561cab03E66dFCC3ebD4b8536f3576f69E5Dc] = true;
        whitelist[0x606316D4550304D0Af7f8b2B0e609959C7294C0F] = true;
        whitelist[0x86269fE8E5704825c3E5dAd4b678c5dB12182152] = true;
        whitelist[0x865faF614Dd07522F2400279b8295Ad518427Df9] = true;
        whitelist[0x3F438Ac3ee8b3e142CDe20Dd812E295c6a05e8ca] = true;
        whitelist[0xCFe7699EF0cb011d1dD6AB345331ba0BB452959E] = true;
        whitelist[0x000007Ba453CFFBd047E1ED8A2C3481BE6563012] = true;
        whitelist[0x0f763a515ea7628B76bCD51c7626405a77531410] = true;
        whitelist[0x1111615a735AC3B3bF3A9Ac75b673509500ac8E8] = true;
        whitelist[0x549d11768Da2C1cA3e896Fc513016EF034de97F2] = true;
        whitelist[0x14b39fe6Ad3c3d2F96B629b7A7D46CD063dc67D4] = true;
        whitelist[0x81c8Ede5B6a3dd3E198De88c297655987EA172eC] = true;
        whitelist[0x81c516261AB29Dd24D9aCC0A1D8CCb822Ad7c982] = true;
        whitelist[0x2eb9916B9c6b7ac84912FFaBd3D165DC0Ba4b788] = true;
        whitelist[0xe853EaaE8AEeB63fD11A6211E8B2C9a47b64EBB6] = true;
        whitelist[0x52eDB5AfC9B84Dde0Ca5c9aB3381308b06973F29] = true;
        whitelist[0x5783CF679BF3713144AD4184B6394a3820Ff28fE] = true;
        whitelist[0x990D66f53313191B2efc99C228B253E907c832e9] = true;
        whitelist[0x11CB75d42eD8C38B3CE7f25d567fc1E1CaCd8749] = true;
        whitelist[0xA0a87dB791CCB14D3663bd2AD1F5D1Ef06AFc931] = true;
        whitelist[0x47c99Ee56ABF622DdfbbfEEe2A18EA25D6f41B55] = true;
        whitelist[0x639eCd1E8ec696fb7187F434545784a5a3e903Ed] = true;
        whitelist[0xFA0c54241c8762a7aE66Dc32c9Fa683DAeCCe840] = true;
        whitelist[0x6Dbd708E1Df3779940E0c5d950f35D73aB0b6752] = true;
        whitelist[0x00B6f70001FF121f3FdE07AB2e962222469093C9] = true;
        whitelist[0x3146b421F3740aB50326f2A8eE3b6cC328F7F7f1] = true;
        whitelist[0xb906fAbbB59901c88E4Ad55CBbcbA769BC15D23d] = true;
        whitelist[0x37369b1f619544589FBb6C6D76C787e623B7B738] = true;
        whitelist[0x3079F63Df53bb3443636A92eB1768efe37E21221] = true;
        whitelist[0xa99b02D5D85C6a0d8335DdE64Bba799D7edD406C] = true;
        whitelist[0x320fCFB09539315b6cE91A77439aA24558751e2a] = true;
        whitelist[0x4956bF53Eb71658C5D829f24769D709fdB08D6B1] = true;
        whitelist[0x4b1A588083818F14ae869B0979B4102328797E37] = true;
        whitelist[0x98297D90D2c29b1A415015AA015B021fBDF06064] = true;
        whitelist[0x8ef3Dd2Ca2899EACD2161A9E1893a855d5469613] = true;
        whitelist[0x000000067184e0478BD4F956a32381FBE7315157] = true;
        whitelist[0xD9aab5257cfcA12e2a6916484BEE15E8F1ED568B] = true;
        whitelist[0x92b046658d5FA9764de1F784C352ad77926B986c] = true;
        whitelist[0x3Db0323804FdCc7b1F27a01B6E0aD3F8db537802] = true;
        whitelist[0x81b892A9674a5BfeE7d4b68D3B717Ab63119edA1] = true;
        whitelist[0x1E12599f58733A8229d904791F38C49be89FbdA4] = true;
        whitelist[0x8b8D474A80824cb4636842953ce0bb8c72627361] = true;
        whitelist[0x192ea605F23EbBFbe27E965bC844A1778CC25380] = true;
        whitelist[0x6398521af73dc0885Bdf7342C769A16De4690AF3] = true;
        whitelist[0x5542F236041265D448720E871dF16115830fe1a8] = true;
        whitelist[0xE06e66772eb84fB02c516d00f273066487058181] = true;
        whitelist[0x24aea31Dd03Dda163e18c376774fFd468754d239] = true;
        whitelist[0xa0753ce6055eeeC2559A82C77B7908B98397dCA7] = true;
        whitelist[0x396532409516F6810e06bd58a297b12c43dCc05A] = true;
        whitelist[0x00e4372e241Dc64d23D6236C19D8652948B24B9B] = true;
        whitelist[0x8aB866bB899f1400167B3B62c7499aaa42AFfDb2] = true;
        whitelist[0xdF84334Df19A78DC7590a118FdFE10A836033398] = true;
        whitelist[0x521cd198BAd0EF6c08828F2C1D086844e1CE4a1E] = true;
        whitelist[0x30D4DAE56eEb08c0089736b7B5E7cc6DCd1244Db] = true;
        whitelist[0x697EA9418AbD8b67979417AC2c7bbC26D8a9929d] = true;
        whitelist[0xDd4CeCDa7cC66Fb8159E8a06127665423Fc18982] = true;
        whitelist[0xb3F5Fc4290Eec2dD598ACc5dD75eB5424f61dddb] = true;
        whitelist[0xf3810fa82607A7674ed8414627d405D0B9ee1327] = true;
        whitelist[0xce0BE726f0dA49694aAF82b402D303704480a53f] = true;
        whitelist[0x8805aECce9c6c1232e876F528D59E89ea9898fe8] = true;
        whitelist[0x435d52DD493A84e3f56bF8F85216cB2A5977cB72] = true;
        whitelist[0xd08e9ca1642396630992B15468C4Cd90f0C195a6] = true;
        whitelist[0x4Ac63de76E235eaA5261d270fEe79A5a55d31E76] = true;
        whitelist[0x4A3E282781760f56D57f0C8190A561903f3F0ca2] = true;
        whitelist[0x913C89054089ebfDC62f6381A64338F2103473Ee] = true;
        whitelist[0x834f4d63B2A3D782340B54D97b2BEAA53E2c20F6] = true;
        whitelist[0x6C1e0B8Ec65c57fD9AFfbE8319E076CD5faff060] = true;
        whitelist[0x77454c18bf20E728CA0b6DA668CAb9B83E05b334] = true;
        whitelist[0x99Ea56b627e2eda6F40C1D3459ED552558351c1A] = true;
        whitelist[0xc2A540158A43019e4f4eE01e34151df9cE4998b0] = true;
        whitelist[0xA657a29d8C848839521b27CdB02d67ad1cef8Ea5] = true;
        whitelist[0x0D79f0F42b7C4Eafc4f0408640A3e0f1701DAA30] = true;
        whitelist[0x0ec4b6790a0611fdafF4461442b5112E20539b82] = true;
        whitelist[0xdA90e2Fd7FEC83Eea87EB1686Bb544cDCf2222C2] = true;
        whitelist[0x0A0D497f948aB961f9380667d4293F056C449F1B] = true;
        whitelist[0xbF62C582f2C694E63B234b570701eCE50ADA905d] = true;
        whitelist[0x9305897B9c108b53FeE0F40C784774bc0cB44Cf6] = true;
        whitelist[0x6c6cF6EEa596EFa13B9994b349c520D0FAFaBcB4] = true;
        whitelist[0xf093210DA74a3FCc6aA5CF611C43429Fc812BBba] = true;
        whitelist[0x0004Eb10136793136C653633FFDe36bf8608dd55] = true;
        whitelist[0xaa8cf5D5e24Bc1A00192C814057710B712ef5188] = true;
        whitelist[0x00000CC02C46EF694238a8ab04Bffa3CEbBDAdcD] = true;
        whitelist[0x8B890C1E2c43480b7b496F87207b3AEB8c3fe688] = true;
        whitelist[0x1B30B85bceda2b749Bcec71DCF290b89A621d6Bb] = true;
        whitelist[0x974254D8995863544A205e15CadD8bEFF9C9e82D] = true;
        whitelist[0x18A6f239E133b04A7089A280Bf48cc84ccca0622] = true;
        whitelist[0x815E46438425b9e8107F711a4d1c984A526504f5] = true;
        whitelist[0xEc84C2C28bFCDeCdC91021d696DD31b344b73125] = true;
        whitelist[0xE72aAc6DA5Ce6Ce160BC44429743C792D96AB8f8] = true;
        whitelist[0x9ffF5bd17167299e897BfDE7B30145632DFe7e22] = true;
        whitelist[0x0E6DC7492C284bE0B296C09C762e4Edcc3F8DFE5] = true;
        whitelist[0xbd60e05f651b325C575368e848BA7B32c105c46e] = true;
        whitelist[0x70AE5E8230D42d4DEd2fB4bcC8D87dF698BAfD5d] = true;
        whitelist[0x14211cFc147eF7eb0045094e41b83Ceb55A0DF9C] = true;
        whitelist[0x0bf6AF64903f8627d557ffB6d8d4d93019E9BBdB] = true;
        whitelist[0xb2bBf8661864C84a62D68F0d9b26Be2F41896c64] = true;
        whitelist[0xD4cee84313e0e02656fA9Bda0090E5F52e7BBBeF] = true;
        whitelist[0xa10b4EdC873ADcD3Feae8413CaE42C41F720Fb64] = true;
        whitelist[0xDd29d1C8AC8A6ce3070cC29103227aD8AFc09550] = true;
        whitelist[0xD804AEEf6980a9c829a485BDdF6c676F14bF3825] = true;
        whitelist[0xE1cc149e5A9470cB9D21A03b0EE3bE5797Bd98F6] = true;
        whitelist[0x4a9EefdCa6d451ea0bBA0F5d9FE17e9D3D5F19CD] = true;
        whitelist[0xEEd073e4af0Bff2284039662Aa9c004a365705F5] = true;
        whitelist[0x1E6d69cc470DAd542e9fDa84E4Be29d93288811D] = true;
        whitelist[0x3987a0F84659727357357c24Fb9B00CdB2332fD8] = true;
        whitelist[0x00000cf0A7C49eE8A671d913Cb483133e0298759] = true;
        whitelist[0xf0aB2494ea0F4C581E816843f387e5eEDd324b5d] = true;
        whitelist[0xfB4b005A6b3d15a6516316ddFfFbC9Dbc0a65338] = true;
        whitelist[0xF9c27590c51147dCbF55af09F7038193bECB1064] = true;
        whitelist[0x0000345677BD3C3A5F816e24445c08218c1CbB78] = true;
        whitelist[0x30448dbBdAdE65674Fbba9616731732dE2CB646C] = true;
        whitelist[0xFD57c0b5D1Dab7e9ca3aC44A59aB31095A17d255] = true;
        whitelist[0x95eBdCB15753FbB61Fba1cDa6DC220Ef4d0b8F9c] = true;
        whitelist[0xc98768daB4Cb4e3176a8A644e2e5BDFeD8e44954] = true;
        whitelist[0xEAd68DCc30B40d824B3A07B36E56D0d703d84BA9] = true;
        whitelist[0x44638385d4B97Ac2ebc06AEC6ef99235bDdA54c4] = true;
        whitelist[0xCe770bfc57d99fc1bfeC30d52930e280Fb41375C] = true;
        whitelist[0x21B3b203Ad2a8b864a775824920B33A8E4A9611f] = true;
        whitelist[0x08f7E61A38435AA429d1D1Cf67904D49091D5aeD] = true;
        whitelist[0xf17d0a02B4860FE7754c05638892168c3C5b48e3] = true;
        whitelist[0xF13C0AEa109939D9136fD7f2507a0064E8024701] = true;
        whitelist[0x4A88E23912ddD61C451d89085B66917DB584bC03] = true;
        whitelist[0x5DAd376750BA3fbE2FF4e9744Ce457c8C8F2324e] = true;
        whitelist[0xC4771cbd55f7C155c2Fe948A62ff3cB9b11eb069] = true;
    }

    modifier claimHasStarted() {
        require(claimEnabled, "sale has not been started.");
        _;
    }
}