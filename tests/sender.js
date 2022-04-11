document.body.querySelector("#connect").addEventListener('click', connect);
document.body.querySelector("#send").addEventListener('click', send);

provider = null
signer = null

let cbalance = document.body.querySelector("#cbalance");
let to = document.body.querySelector("#to");
let amount = document.body.querySelector("#amount");
let claim_period = document.body.querySelector("#claim_period");
let address_output= document.body.querySelector('#connected_address')
let network_output= document.body.querySelector('#network')
let warning_area  = document.body.querySelector("#warning")



let connected_address = null
let network = null
let RetrackProtocol = null

async function connect(){

   
    if (!(window.ethereum)) {
        address_output.innerHTML = "Wallet not found";
        return
    }

    if (!(ethereum.isConnected())){
        try {
            const addressArray = await window.ethereum.request({
              method: "eth_requestAccounts",
            });
            console.log(addressArray)
            address_output.innerHTML =  addressArray[0]
            connected_address = addressArray[0]
           

        } catch (err) {
            address_output.innerHTML =  "Connection rejected"
            return
        }
    }
    
    const addressArray = await ethereum.request({
            method: "eth_requestAccounts",});

    address_output.innerHTML =  addressArray[0]
    connected_address = addressArray[0]

   
    let network_id = await ethereum.request({ method: 'eth_chainId' });
    network_output.innerHTML = parseInt(network_id)
    network = parseInt(network_id)

    let balance = await ethereum.request({ method: 'eth_getBalance', 
                params:[connected_address, 'latest'] });
    cbalance.value = parseInt(balance) / 10e17

    
    if (provider == null)
    {   
        provider = new ethers.providers.Web3Provider(window.ethereum)
        signer = provider.getSigner()
        if (!RetrackProtocol){
            RetrackProtocol = new ethers.Contract(RetrackProtocol_address, RetrackProtocol_abi);
            RetrackProtocol = RetrackProtocol.connect(signer)
        }
    }
    
}

function update_temp(area, value, time=5000){
    area.innerHTML = value
    setTimeout(()=>{area.innerHTML=""}, time)
}

async function send(){

    if (!connected_address){
        update_temp(warning_area, "First connect");
        return;
    }

    if (network !== 1666700000){
        update_temp(warning_area, 
            `WARNING: Test program is currently only ment to be used on 
            ropsten network, dont loose your money change your network`);
        return;
    }

    if (!to.value || !amount.value || !claim_period.value){
        update_temp(warning_area, "To address, amount and claim period can't be empty!");
        return;
    }

    if (!RetrackProtocol){
        update_temp(warning_area, "Couldn't find contract!");
        return;
    }


    
    const tx = await RetrackProtocol.send(to.value, parseInt(claim_period.value), { 'value': ethers.utils.parseEther(amount.value)});
    console.log(tx)
}
     
// What if we free the blockchain from the internate
// A truely decenteralized internate 