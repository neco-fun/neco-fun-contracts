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
        whitelist[0x766B35AbD89D56c13e5cd84C9619D361B4CA7656] = true;
        whitelist[0xBfd0Fe82C81d2319D7a536B4126f7353Be2b1338] = true;
        whitelist[0x1Dba3dEc4eB8Bd12E10fdbEa953b0a407FBe4e51] = true;
        whitelist[0x42b24a2D909A5e2595EBa09801FAf3796b9991A8] = true;
        whitelist[0x9eB83A8f95360ef7F14C84205AAaB0e9c52404D9] = true;
        whitelist[0x01808342a9EcF0C6A1c4D26025a2c87550652d3f] = true;
        whitelist[0x02AC6aE96D65f51aFa2799d440458Addd0692ccd] = true;
        whitelist[0x0821ebCf9aa2f6655423941E397Cd93878CE3e03] = true;
        whitelist[0xAf02C8bbc851c0E7ea46118294a4e38fB03d209E] = true;
        whitelist[0x2d2C703d0997e610aab296aB0559DD22d16A11b5] = true;
        whitelist[0xbaC38B4FD381c4106Dba1843273ab6B66C42B010] = true;
        whitelist[0x281A59EA6Bf10E3c076B519a98bD3E01D4852A9f] = true;
        whitelist[0x2e1a2bF9700ff4c6560af61a8b526e746d7bB790] = true;
        whitelist[0x3B0F627E5051c40Cf2787C9cd954E40a3d44E753] = true;
        whitelist[0xfDfDA74943b609f27D8D90b37527F85f0F8938E3] = true;
        whitelist[0xff278CD2Ae167060407456f1B596e9aEFBb1B16d] = true;
        whitelist[0x47eD23ca69ac92De77FbF6A2Ffe8ebAF7254Ea0F] = true;
        whitelist[0xFf4aCfd3bE0C851bE759A0491E6D6c85FeA96aFE] = true;
        whitelist[0x5Cb87024F681fE07968438d3C0a21b92edf90Eb0] = true;
        whitelist[0x341109d3326CDfAe15c57b2bBecFE9d64a4948CC] = true;
        whitelist[0x2D244f32F1Df779271f920EBFd54B8D9b9a2BF4B] = true;
        whitelist[0x2BbBad38c539C8e787C9eA4d92d47AB854E4fcD7] = true;
        whitelist[0x01fc6E45F02c450eA501c82456b8f7133ce8777E] = true;
        whitelist[0x56Ce5CE1fBceb0d93B82d2f13a1B0eF89ab8fDF3] = true;
        whitelist[0xc9B76B3B1eeBacBfd6Fa4Da16b5570E02734Ed27] = true;
        whitelist[0x686f1afEf833bC62D97D791eA52fDB54c15c2477] = true;
        whitelist[0xfAC531B8e61220314465da51a850d01f0a4764Cb] = true;
        whitelist[0x15A6A0C0230AedcE0C6BEaD2e7Ef05F9708Ec6C6] = true;
        whitelist[0x0432ec9d8A4b568f9F5d63C3D79f63a6019d9516] = true;
        whitelist[0x44b274318D132256DbDbCe0a399fd4eF3738Cf07] = true;
        whitelist[0x9f821DD55fcD27ab739185f8dE132f7006342397] = true;
        whitelist[0x8bFed921CB1A1493372A6F8748DFb99B2D95daF3] = true;
        whitelist[0x416907B94b2550491495083048Bc4872E8b12593] = true;
        whitelist[0x6fA421176520b2d70069102f5dD44b7120c3b6ae] = true;
        whitelist[0x5feC436D727273115d56aCc31EdA90298512135C] = true;
        whitelist[0x175B8BBD10563E05A8b3B4607265Bc24ACE6732d] = true;
        whitelist[0x21bf7496D7Fc5FC95E82FA6A316826CdD5Bcc007] = true;
        whitelist[0x8F52F5EAFFA522ffEf4577687041188e34FE8081] = true;
        whitelist[0x0F68924a16363F667E554C0F5bC96d43be65b987] = true;
        whitelist[0x498b3ab735e74d6809ef0C1cE900AEA3436a8210] = true;
        whitelist[0x3E2f76d412e307DE99a0df73cE5F20Fa6917D868] = true;
        whitelist[0xf2Bb35517b84E2E435Fd8f5D0E4ABD09C3D1C6e5] = true;
        whitelist[0xCdb2721255728f7a17A8b04C24C564e263c951Bd] = true;
        whitelist[0xB411A230894d6d0b8CF43A94C001B8FC7789d6a2] = true;
        whitelist[0xdE397C09D73BfD8f224CaCffD967e5c036102481] = true;
        whitelist[0x000000078547149D913eA841beb93da76D0C7e25] = true;
        whitelist[0x7504c0623207b0673D9f0FeD74bA2aCBEF94bBAc] = true;
        whitelist[0xde520825Ca647F06099f0A3Da575758EF2fb8ecC] = true;
        whitelist[0xf3b314D2874780c3fb36C5381E369De1d027426F] = true;
        whitelist[0x51a9a3Df0B784EB45f32De3BD266444B0DcBf062] = true;
        whitelist[0xDD474B80D5EC7F0CF986eD7FBEe2a7b4Cdc73153] = true;
        whitelist[0xB1C5e15f452DB498Dd91cef17a35a9174F8dB114] = true;
        whitelist[0xA8F53fBeB53D76379FC7F9a9Ee6D9F5c9291d022] = true;
        whitelist[0xA5f3aB0a86A8F77aDDcF3e667A38DcBa49cd8131] = true;
        whitelist[0xCeC0927A3cDBb73CF005848a67da7369F5FBBC50] = true;
        whitelist[0x372558CF4A021C81FaF54b1e803E70441ACF3E13] = true;
        whitelist[0xB93971aF0CA58232a4512eFfcd55B659C4ab37d6] = true;
        whitelist[0xd167827E2be1c121ebb4593885F773e558a7Cc65] = true;
        whitelist[0xF14ABCc22f508303DeEdbAb3852D948326B3e20b] = true;
        whitelist[0x91B92b90dBA011Ba1612ad98c172D61225553a5b] = true;
        whitelist[0xf8c2d516be48Ea4e34E258d7C4A108a1F8fD6499] = true;
        whitelist[0x14BD1b847250DD31571207bB28418e81aaA8b690] = true;
        whitelist[0xE3317D1be46B01ACD22364da2F72Aa49b5c2DE44] = true;
        whitelist[0x2A44A160CEE1D14C78aB42d33A791915c2B10e75] = true;
        whitelist[0xF63739098030A5b4C7A7BEE82c7A27bAC3f6D966] = true;
        whitelist[0x88E79b7DF78e77cd1ffB1b897b3F5D8aba9b4aCe] = true;
        whitelist[0x3E8d6a12521e4005805a8964c7C8E6C9c348e92D] = true;
        whitelist[0x0b0999F25c4Bcc74baCE7cB1Adf5Fc7662e29e83] = true;
        whitelist[0x43DB7D4Aa576B8B762be46179d70d5DfadE9d8ec] = true;
        whitelist[0x3F5Be717697BF496D6227bF88bdfd8f6C7786b26] = true;
        whitelist[0xbB50C7575d98c47C417206E7BEF8C809f6EBcBbe] = true;
        whitelist[0xadb3e537622aBf6b7789C6F8C3BE3C6e7f6B68B1] = true;
        whitelist[0xadb3e537622aBf6b7789C6F8C3BE3C6e7f6B68B1] = true;
        whitelist[0x9EEeE17D26133f8A0F70d7F06A9848e6ED6412CF] = true;
        whitelist[0x686075106D696Ba8f32CBBCFc7BCc837788Dfff9] = true;
        whitelist[0x414F1547892f47E836B64eDf98898C9053adB480] = true;
        whitelist[0x00002031e3fA8C90e8EF3645Db9840042A5afbdD] = true;
        whitelist[0x95C6b49ffDf82c1025DB99D51e1139286C5766ad] = true;
        whitelist[0x000006acbb0a45cF7bD74AfA91a4A01045134Ee6] = true;
        whitelist[0xf3d802F860A40624dA9F58D096605cf771544BaD] = true;
        whitelist[0x35b1acb1658775F03056D3BD4bA799dAB2Df3BD8] = true;
        whitelist[0x86EEecc1A5D44785F6AeBB3B1e4c4deb4D13414E] = true;
        whitelist[0xAbAB9104130e34F06399B2CBFaD1dfBD82f8B055] = true;
        whitelist[0x0000003f25f9E4D1b71ab5bdF48D04E744D52267] = true;
        whitelist[0xe67ABECA0822F15844eb8A757AbACB61fD7bD79c] = true;
        whitelist[0xCE97fb540B8f73E991bbF951a9eA4ff734F73E6a] = true;
        whitelist[0x80000029e555e0A0F6CADDE77BCb2b7284adB7ab] = true;
        whitelist[0x4A3E282781760f56D57f0C8190A561903f3F0ca2] = true;
        whitelist[0xa8B1b971968420C0bA4413bCFd1cc4C87AbB3A98] = true;
        whitelist[0xEd927B4375EA9987cF024D8523E31c24Dad9FfE3] = true;
        whitelist[0x8d779846A7A0A85452C23ecdfe76b6109C8ebDA8] = true;
        whitelist[0x30004D41ed960F88D0D0d8773131616498Af5c24] = true;
        whitelist[0x1C4C0956c7BAAA27664099e2bd3e0A507C4Bd7b0] = true;
        whitelist[0x3d1027769f230BBc53199ea0dE231657B728C5bc] = true;
        whitelist[0xC10318f2fEaFCA0B13Cca86F8Bbaa78033227e71] = true;
        whitelist[0xaA6d14E5e7a19Cf1Cad102090bC3494896E3B117] = true;
        whitelist[0x87B0Fc4959C55dA41df0Ef88537977D5ef0BB7cF] = true;
        whitelist[0x3189a6C511f0Ebb5E6332074741485ADe089aF9E] = true;
        whitelist[0xe8272d809325871745750A7225BF85671568f078] = true;
        whitelist[0xb8E91AD8741999501cC7ff5E32E92d44962A6c80] = true;
        whitelist[0xd0514E154c4F22af658a57713aA4e62e03725aF1] = true;
        whitelist[0xD69D20bD6755E0014f6507Ea3C9c655667882FD3] = true;
        whitelist[0x881b14e01a43A7637FaBed96512d4Da011084F1D] = true;
        whitelist[0xeC44aA9632190B9e8F68E66E043e2A7A5697e9A7] = true;
        whitelist[0x49e056d7d0F68D343b4B2b398bd1C68C146fCe83] = true;
        whitelist[0x82210d0E9c4F26d9d73799D5b7c5272C3CD1ddA3] = true;
        whitelist[0x7FE3FD1D6C0B30BCE34c0Df198Ae02194fA44Bd0] = true;
        whitelist[0x716E40f6991e797C4dB129F8e074f75A34cacca3] = true;
        whitelist[0x4e2d8E265590A4d22E98D46aEC260dc04e8c478d] = true;
        whitelist[0x89285a82f2a26bE4391ED98a20eD824509928c7d] = true;
        whitelist[0xa3160150C41f069023E5678c3514a031c9024C26] = true;
        whitelist[0x0000A40b8300A761B900d5f8b1391B5fc5414ACc] = true;
        whitelist[0x647ad318601D2b276ab8C78D087987a79cFA3442] = true;
        whitelist[0xE4df3390a4b017AEb1F428E84E634B40860CBa1C] = true;
        whitelist[0xD281e4fe58EEcc9790C3c986bdE3f65288789545] = true;
        whitelist[0x81E62204648a7Feeb6c43B13cb87a02Efd4994A2] = true;
        whitelist[0xFe65116E78059e738555c2b7b80921832741f4Fc] = true;
        whitelist[0x3060f60Bc426BF7E0F20C82e48B4716Bd6085aC6] = true;
        whitelist[0x0000D59d390DEb5C490472F662157b3967cADFF5] = true;
        whitelist[0xCA1CAD1F4Ad867caD1890Fb0e441C4A514F86D41] = true;
        whitelist[0x9198dfd2914cdE6470080bbA5d56219A767de826] = true;
        whitelist[0x4C6d1070A8B52f6E4e1c9D0F85aAd6664007E158] = true;
        whitelist[0x409fc37E90683839DA4088b271d9Ff9998291D61] = true;
        whitelist[0x62Eb63C4F601cf357B06c158Bb7CA747778d2c49] = true;
        whitelist[0x82bd76c280D53CD7747D7FDFA3eC297e59ab1Ab5] = true;
        whitelist[0xb872c73229F2B8710AEb966072472811F8ce20c2] = true;
        whitelist[0x8bB57282dCFf57e03347B6397Bee0f040CC093EF] = true;
        whitelist[0x05AB45B8A9721c3014d671b10ab5A90158b5Ff3c] = true;
        whitelist[0x14710DB7284BE605CF9434052F76Ea91061748d9] = true;
        whitelist[0xF3B0F31D8B8215B71Fb784Db93ea1c38b6061Ffe] = true;
        whitelist[0x70A7796B5B0bc6153E344A4C60d79D68CCf38A85] = true;
        whitelist[0x550090Ef057315E9C7c57d8005A9A21f1F24b25D] = true;
        whitelist[0xF511470999e3F45550b886a3b483cDE0AD1B7201] = true;
        whitelist[0x894a525f7099Aa5b935a3A8C0373acf27594e2b9] = true;
        whitelist[0xdC0a01219D6612efDa4E6996E7C367e86924f164] = true;
        whitelist[0x85C4eD1b0ccD94a46E760f7ba7AF91E37C8CF9fc] = true;
        whitelist[0xd8ee47E0B2f1f35BEc99C51f6a2E3a6Ce95E616D] = true;
        whitelist[0xbde7FbBDBa235D802A96E1D2ac8eA4Dd6512295b] = true;
        whitelist[0x39B644aC0659EA17EA416cf1A67bbe719b29DB01] = true;
        whitelist[0x048Ef5dd68c0f15950574cD2E93FE499F43D0822] = true;
        whitelist[0x997472D6fed4C7f303678426dA187CBB812d2154] = true;
        whitelist[0x6FD8ed9E6Dc443de7738Beb598ACa9320Cb5847B] = true;
        whitelist[0xdEe2EDeB6A428f5f1693B663BF8f05e4dC65DEdB] = true;
        whitelist[0x1cd12db1D4E8c5d58566923147Cf5a7e9C3AB288] = true;
        whitelist[0x6cCddc06415f66bAfd6499A189f8C212c143BFf1] = true;
        whitelist[0x1f50b54217984B836E5E0Cc7c5827980CE60d072] = true;
        whitelist[0x2835195E01c0856b642f7f07671D1277B9FC5c7C] = true;
        whitelist[0x29400ccD7a00B09eE01f0cE2fBcEF3B4B5b40382] = true;
        whitelist[0x417e1fE213D6C71e493d0fAd26B10Bc267b00f8e] = true;
        whitelist[0x01ebEc60710212C10853DDa53Af5DC89430F219f] = true;
        whitelist[0x4BD31b77efcb699f478f6d68b1db0A8A3529194b] = true;
        whitelist[0xE48A5F935a2E8471B1D8bCCa783A00D5B2ED1594] = true;
        whitelist[0xB1D7D9FaE4C63AfDe60966c0d6C3CEf9EA10c45c] = true;
        whitelist[0x5aad90569345b0ab17a70Ff25A54569E8F70619f] = true;
        whitelist[0xa551641D51a84780348a9713a1f1A4664F13Cf17] = true;
        whitelist[0x00000098904C5161E76a6B2DF5523190B4Bc7637] = true;
        whitelist[0xDb30128FdbD4aeF26305c78E7B1Fc50958F24644] = true;
        whitelist[0xD21BB343b596f2B80D10804963f3B0917A6B9bcd] = true;
        whitelist[0xB54a10c6AEAFC01b847b65db9916f051627e5765] = true;
        whitelist[0x7944b9376a18e07e6114E0397247AA51191509Db] = true;
        whitelist[0x2aEfc99091420218De94D8b446d29F08189a3B0c] = true;
        whitelist[0x3bf9bcE00785904572A83Bc1c63012f99a92f648] = true;
        whitelist[0xa2D2ed6F0C672BE216C03982f4eA61D5e0e4d1df] = true;
        whitelist[0x35620266C9e2ef1cF00eBE7c4B30554765C114e9] = true;
        whitelist[0x11111D8aB0eb0102106F0315aBacd8de0E105838] = true;
        whitelist[0x360cEBaC3453204D44032d4E4d2c9896DE48a85c] = true;
        whitelist[0x65CB60a90CaBe17838E98e57Ce46b70126F47ACF] = true;
        whitelist[0x856dba7E4a0453f149F6c2970073De585Fbaaf00] = true;
        whitelist[0xA1141c17F86015614960FA4019F72d8b1cEC313A] = true;
        whitelist[0x9C8df4511D9B84d1773FDEa10bdD8327EA8E44c9] = true;
        whitelist[0xaa27Da06350a67E6E2fc59E20767949e326c0FBd] = true;
        whitelist[0xF37d3E9E0cF48370819bEE7B01575990ca524c0B] = true;
        whitelist[0x9E9bc2485e9FbdCb41775d08Ad0E2Bc5A7655DfB] = true;
        whitelist[0x439b4836669Afb8E6F510a4503cBd6104440002e] = true;
        whitelist[0xfaFf468E05762571A34337bDDea43f73970f0043] = true;
        whitelist[0x162DdEfb99E76ccb65d8607Ae40360be2C8e98A5] = true;
        whitelist[0x573Ddb7231ac41AaA0bafC41073926ea758a5cED] = true;
        whitelist[0xd915185860C732c991bE071948e24a1d01F062f6] = true;
        whitelist[0xbA18780104D1eeea05d3183a83a9eaF3180618BB] = true;
        whitelist[0x2047451089abE0796ED5b4D35f71CAA99Ed4a314] = true;
        whitelist[0x27589783293f8Ba16164c55A31E00b08412c0f1B] = true;
        whitelist[0x03863382E059A87c510B6d43C901850830cb1C9B] = true;
        whitelist[0x48121a6D473288d9cC959aF28C6be88ba46eFEA6] = true;
        whitelist[0x99c4bed2a1216386F7F06CFb9Ed6c3027d35223A] = true;
        whitelist[0x369320339336fBf4cd25815B93532dc33b029841] = true;
        whitelist[0xad02A594FAeBeE9d4eF69a2c3e3820A8255781e2] = true;
        whitelist[0xf294C051c6D47486f15ce0D33972fbcbF3Ba8Df9] = true;
        whitelist[0xb1D53CbD6eA38CE81DF05b2834987cAC3E6fA7CD] = true;
        whitelist[0x038A3a4552301FC6cFe5befe48FbE96FC47333b0] = true;
        whitelist[0x22a429cEAA0391Bdd71B0718bcf8fdE5005EC2d6] = true;
        whitelist[0x5783CF679BF3713144AD4184B6394a3820Ff28fE] = true;
        whitelist[0x37369b1f619544589FBb6C6D76C787e623B7B738] = true;
        whitelist[0x98297D90D2c29b1A415015AA015B021fBDF06064] = true;
        whitelist[0x14211cFc147eF7eb0045094e41b83Ceb55A0DF9C] = true;
        whitelist[0xb2bBf8661864C84a62D68F0d9b26Be2F41896c64] = true;
        whitelist[0xD804AEEf6980a9c829a485BDdF6c676F14bF3825] = true;
        whitelist[0xEEd073e4af0Bff2284039662Aa9c004a365705F5] = true;
        whitelist[0xfB4b005A6b3d15a6516316ddFfFbC9Dbc0a65338] = true;
        whitelist[0xFD57c0b5D1Dab7e9ca3aC44A59aB31095A17d255] = true;
        whitelist[0x21B3b203Ad2a8b864a775824920B33A8E4A9611f] = true;
    }

    modifier claimHasStarted() {
        require(claimEnabled, "sale has not been started.");
        _;
    }
}