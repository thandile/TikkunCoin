$('#privacy').click(function(){
alert("Privacy Settings are currently" + 
	"being updated in terms of the newest privacy best practices around the world.");
})

$('#terms').click(function(){
alert("Terms can be viewed on our main website: www.tikkuncoin.co.za");
})

$('#button').click(function(){
alert("We will try get back to you within the next 2 working days.");
})

$(".details").mouseenter(function(){
	alert("Details Can be found in our White Paper")
})

$(".rounded-circle").hover(function(){
    $(this).animate({
    	height:'+=50px',
        width:'+=50px',
        opacity: '0.8'
    });
 })

$("#contact").hover(function(){
    $(this).animate({
           fontSize: '3em'
        });
});  

$("#contact").click(function(){
        var contact = $("#contact");  
        contact.animate({fontSize: '3em'}, "slow");
    })