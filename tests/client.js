document.body.querySelector("#check_status").addEventListener( 'click', check_status);

function check_status(){

    if (!signer){
        update_temp(warning_area, "First connect");
        return;
    }

 
   let events = RetrackProtocol.filters.MoneyTransferred(null,connected_address, null);
   console.log(events)

}

// update_temp(client_msg, "No recieved history", 200000);

