document.body.querySelector("#check_status").addEventListener( 'click', check_status);
let recieved_monies = document.body.querySelector(".recieved_moneys");

function upddate_state(from, amount){
    let redeem_div = `
    <div class="reedem-card">

    <span>From <p id="sender_address">${from}</p></span>

    <div class="redeem-group">
        <div class="form__group">
            <input type="input" class="form__field" name="redeem_amount" id='redeem_amount' value="${amount}" required />
            <label for="redeem_amount" class="form__label">Reedem amount</label>
        </div>
        <button class="action__btn" id="reedem">Redeem</button>
    </div>
    
 </div>
    `
    
    recieved_monies.innerHTML += redeem_div;
    

}
async function check_status(){

    if (!signer){
        update_temp(warning_area, "First connect");
        return;
    }

 
   let filter = RetrackProtocol.filters.MoneyTransferred(null, connected_address, null);

   let events = await RetrackProtocol.queryFilter(filter, -100000);

   events.forEach((event) => {let {amount, from} = event.args; upddate_state(from, ethers.utils.formatEther(amount._hex))})


   RetrackProtocol.on(filter, (event) => {let {amount, from} = event.args; upddate_state(from, ethers.utils.formatEther(amount._hex))});


}

// update_temp(client_msg, "No recieved history", 200000);

